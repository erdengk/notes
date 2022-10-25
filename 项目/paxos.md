### paxos 究竟在解决什么问题 ？

用来确定一个不可变变量的取值



### paxos 如何在分布式存储系统中应用 ？

![image-20221020170035390](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210201700506.png)

![image-20221020171438611](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210201714663.png)





![image-20221020171452991](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210201714036.png)



![image-20221020171524896](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210201715951.png)

![image-20221020171616399](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210201716459.png)

![image-20221020171655547](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210201716584.png)



![image-20221020171853060](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210201718083.png)



### paxos 算法的核心思想是什么 ？







知行学社——paxos和分布式系统https://www.bilibili.com/video/BV1Lt411m7cW





----

共识介绍

共识Consensus问题:
	在一组允许出现故障的成员中，如何从一组提案中就某一个提案达成共识

共识与一致性:

​	共识强调在外部观察者看来，系统数据是一致的
​	一致性，是指系统内部真实100%-致



基本保证:
	已达成共识的提案不会因为任何变故而改变

提案编号

多数派:
	超过集群一半成员组成集合
	l(N)2| +1 (N为成员总数)



角色

proposer

acceptor

learner



阶段

prepare 阶段	

​	争取本轮提出提案的所有权

​	prpare阶段propose是不会携带提案值的，它只会携带提案编号广播给所有的acceptor，所有的acceptor 根据这个提案编号判断是不是能够接受这个prepare请求

​	当proposer收到集群中大多数acceptor的同意之后，然后它就拥有本轮提出提案的权利，那么它就可以进行accept阶段

​	另一个作用，就是获取上一轮可能达成共识的提案（已经达成共识的值不可改变了）。它会把prepare请求广播给所有的acceptor时，acceptor会把它本地曾接收过的一个提案反馈给 proposer

​	

accept阶段

​	获取上一轮

learn阶段







协商约定

Acceptor:令自己所见过的最大的提案编号为local.n，请求中的提案编号为msg.n

收到Prepare请求，msgn> localn，则通过该请求，否则拒绝该请求，直接抛弃该请求。

收到Accepl请求，msg.n ≥localn,则通过该请求，否则拒绝该请求，直接抛弃该请求。

通过某一Prepare请求时，会在Prepare响应中携带自已所批准过的最大提案编号对应的提案值。

Proposer:
收到客户端请求，先发起Prepare请求。
收到多数派Prepare响应， 才可以进入Accept阶段。 其提案值需要从Prepare响应中获取。
收到多数派Accepl响应，则该提案达成识。





![image-20221021114356513](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210211143545.png)



![image-20221021114605616](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210211146652.png)





四轮消息响应

![image-20221021114916475](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210211149502.png)





活锁 多个proposer 之间并行提案，它们之间会互相影响

![image-20221021114955364](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210211149399.png)







### Multi paxos

引入Leader角色
	只能由Lcaded发起捉案，减少了活锁的概率
优化Prepare阶段
	在没有提案冲突的情况下，优化Prcpare阶段， 优化成一阶段







![image-20221021115230466](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210211152500.png)



【分布式一致性/共识算法 - Multi Paxos】 https://www.bilibili.com/video/BV1Y34y1j7b1?share_source=copy_web&vd_source=4d050090b394b684b27865dbb93eb184



![image-20221021115314630](https://raw.githubusercontent.com/erdengk/picGo/main/img/202210211153657.png)





https://www.bilibili.com/video/BV1X54y1d7xU