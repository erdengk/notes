## 对zk的理解

可以从分布式中三种应用场景来说

==集群管理==

在多个节点组成的集群中，为了去保证集群的高可用特性

每个节点都会去冗余一份数据副本，在这种情况下，需要保证客户端访问集群中任意一个节点都是最新的数据

==分布式锁==

如何保证跨进厂的共享资源的并发安全性

对于分布式系统来说，也是一个比较大的挑战，而为了达到这个目的，必须要使用跨进程的锁，也就是分布式锁来实现

==master选举==

为了降低集群数据同步的复杂度，一般会存在master和slave两种角色的节点。master去做事务和非事务性的请求处理，slave负责去做非事务的请求处理，但是在分布式系统中如何确定某个节点是master还是slave也是一个需要解决的问题。

基于这些需求，所以产生了zk这样的中间件，它是一个分布式协调中间件。它类似一个裁判，专门来负责协调和解决分布式中的各类问题。

zk实现了cp模型，来保证集群中的每一个节点的数据一致性。zk本身不是一个线性一致性模型，而是一个顺序一致性模型。

分布式锁，zk提供了多种不同的节点类型 持久化节点、临时节点、有序节点、容器节点，对于分布式锁来说，zk可以利用有序节点的特性来实现 ，初次之外，还可以用同一级节点的唯一特性来实现分布式锁

对于master选举，zk可以利用持久化节点来存储和管理其他集群节点的一些信息，从而去进行master选举。目前Kafka、habase都是通过zk来实现集群中节点的一个主从选举

zk就是一个分布式数据一致性的解决方案，主要解决分布式应用中一些 高可用的需要严格控制访问顺序的一些场景，实现分布式的协调服务，底层的一致性算法是基于Paxos演化后的ZAB协议。

## 讲讲zab协议

### 为什么有zab

paxos并没有给出完整且正确的实现，比如像节点扩容、奔溃恢复这些功能并没有提及，

所以zk中实现了zab这个原子广播协议来完成它的需求。基于Fast Paxos算法实现。

#### 活锁问题

#### 复杂度问题

为了解决活锁问题，出现了multi-paxos；

为了解决通信次数较多的问题，出现了fast-paxos；

为了尽量减少冲突，出现了epaxos。

可以看到，工业级实现需要考虑更多的方面，诸如性能，异常等等。这也是许多分布式的一致性框架并非真正基于paxos来实现的原因。

#### 全序问题

对于paxos算法来说，不能保证两次提交最终的顺序，而zookeeper需要做到这点。（先买了咖啡才能和咖啡，反之不可以）







### zxid、epoch、xid

在 ZAB 中有三个很重要的数据：

- `zxid`： 一个 `64 位长度的 Long 类型`，其中高 32 位表示纪元 epoch，低 32 位表示事务标识 xid。即 zxid 由两部分构成： epoch 与 xid。
- `epoch`：`抽取自 zxid 中的高 32 位`。每个 Leader 都会具有一个不同的 epoch 值，表示一个时期、时代、年号。每一次新的选举结束后都会生成一个新的 epoch，新的 Leader产生，则会更新所有 zkServer 的 zxid 中的 epoch。
- `xid`：`抽取自 zxid 中的低 32 位`。为 zk 的事务 id，`每一个写操作都是一个事务`，都会有一个 xid。 xid 为一个`依次递增的流水号`。

### 三阶段（leader选举、广播阶段、恢复阶段）

### 消息广播

- 类似于一个**二阶段提交**过程。

- 当过半的follower反馈ack之后就可以提交事务Proposal(提案)了。

- 但是该模型无法处理leader崩溃退出而带来的数据不一致问题。因此，在ZAB协议中添加了另一模式，即采用**崩溃恢复模式**来解决这个问题。

- Leader 接收到消息请求后，将消息赋予一个全局唯一的 64 位自增 id，叫做：zxid，通过 zxid 的大小比较即可实现因果有序这一特性。

- Leader 通过先进先出队列（会给每个follower都创建一个队列，保证发送的顺序性）（通过 TCP 协议来实现，以此实现了全局有序这一特性）将带有 zxid 的消息作为一个提案（proposal）分发给所有 follower。

- 当 follower 接收到 proposal，先将 proposal 写到本地事务日志，写事务成功后再向 leader 回一个 ACK。

- 当 leader 接收到过半的 ACKs 后，leader 就向所有 follower 发送 COMMIT 命令，同意会在本地执行该消息

- 当 follower 收到消息的 COMMIT 命令时，就会执行该消

- 在消息广播过程中，leader server会为每个follower分配一个单独的**队列**，然后将需要广播的事务proposal依次放入这些队列中，并且根据FIFO策略发送消息。

  每个follower接收到proposal后，会首先将其**以事务日志形式写入本地磁盘**，并且在成功写入后(ack)反馈给leader。**当leader收到超过半数的ack后，会广播一个commit消息**给所有的follower以通知其进行事务提交，同时leader自身也会完成对事务的提交，follower也会在接收到commit消息后，完成对事务的提交。(提交至内存)



## 可靠性保证

已经被leader提交的事务需要最终被所有的机器提交（已经发出commit了）

保证丢弃那些只在leader上提出的事务。（只在leader上提出了proposal，还没有收到回应，还没有进行提交）



### leader提交的，需要被全局提交

当 leader 收到合法数量 follower 的 ACKs 后，就向各个 follower 广播 COMMIT 命令，同时也会在本地执行 COMMIT 并向连接的客户端返回「成功」。

但是如果在各个 follower 在收到 COMMIT 命令前 leader 就挂了，导致剩下的服务器并没有执行都这条消息。

#### 解决方案

选举拥有 proposal 最大值（即 zxid 最大） 的节点作为新的 leader：由于所有提案被 COMMIT 之前必须有合法数量的 follower ACK，即必须有合法数量的服务器的事务日志上有该提案的 proposal，因此，只要有合法数量的节点正常工作，就必然有一个节点保存了所有被 COMMIT 消息的 proposal 状态。

新的 leader 将自己事务日志中 proposal 但未 COMMIT 的消息处理。

新的 leader 与 follower 建立先进先出的队列， 先将自身有而 follower 没有的 proposal 发送给 follower，再将这些 proposal 的 COMMIT 命令发送给 follower，以保证所有的 follower 都保存了所有的 proposal、所有的 follower 都处理了所有的消息。通过以上策略，能保证已经被处理的消息不会丢

### 只在leader提交未广播的，需要丢弃

当 leader 接收到消息请求生成 proposal 后就挂了，其他 follower 并没有收到此 proposal，因此经过恢复模式重新选了 leader 后，这条消息是被跳过的。 此时，之前挂了的 leader 重新启动并注册成了 follower，他保留了被跳过消息的 proposal 状态，与整个系统的状态是不一致的，需要将其删除。

#### 解决方案

Zab 通过巧妙的设计 zxid 来实现这一目的。一个 zxid 是64位，高 32 是纪元（epoch）编号，每经过一次 leader 选举产生一个新的 leader，新 leader 会将 epoch 号 +1。低 32 位是消息计数器，每接收到一条消息这个值 +1，新 leader 选举后这个值重置为 0。

这样设计的好处是旧的 leader 挂了后重启，它不会被选举为 leader，因为此时它的 zxid 肯定小于当前的新 leader。当旧的 leader 作为 follower 接入新的 leader 后，新的 leader 会让它将所有的拥有旧的 epoch 号的未被 COMMIT 的 proposal 清除。

每次变换一个leader，则epoch加一，可以理解为改朝换代了，新朝代的zxid必然比旧朝代的zxid大，新代的leader可以要求将旧朝代的proposal清除。





https://zhuanlan.zhihu.com/p/75720517

https://www.cnblogs.com/felixzh/p/5869212.html

https://juejin.cn/post/7099251134333714440

http://wangwren.com/2019/09/02-Zookeeper%E7%90%86%E8%AE%BA%E7%9B%B8%E5%85%B3%E2%80%94%E2%80%94Paxos%E5%92%8CZAB/#Paxos%E7%AE%97%E6%B3%95