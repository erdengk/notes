# JUC工具类: CountDownLatch详解

CountDownLatch底层也是由AQS，用来同步一个或多个任务的常用并发工具类，强制它们等待由其他任务执行的一组操作完成。

七个人分别去找龙珠，然后主线程去召唤。

### 面试题

什么是CountDownLatch?

CountDownLatch底层实现原理?

CountDownLatch一次可以唤醒几个任务? 多个

CountDownLatch有哪些主要方法? await(),countDown()

CountDownLatch适用于什么场景?

写道题：实现一个容器，提供两个方法，add，size 写两个线程，线程1添加10个元素到容器中，线程2实现监控元素的个数，当个数到5个时，线程2给出提示并结束? 使用CountDownLatch 代替wait notify 好处。

### CountDownLatch介绍

从源码可知，其底层是由AQS提供支持，所以其数据结构可以参考AQS的数据结构，而AQS的数据结构核心就是两个虚拟队列: 同步队列sync queue 和条件队列condition queue，不同的条件会有不同的条件队列。

CountDownLatch典型的用法是将一个程序分为n个互相独立的可解决任务，并创建值为n的CountDownLatch。

当每一个任务完成时，都会这个锁存器上调用countDown，等待问题被解决的任务调用这个锁存器的await，将他们自己拦住，直至锁存器计数结束。

###  CountDownLatch示例

```java
import java.util.concurrent.CountDownLatch;

class MyThread extends Thread {
    private CountDownLatch countDownLatch;
    
    public MyThread(String name, CountDownLatch countDownLatch) {
        super(name);
        this.countDownLatch = countDownLatch;
    }
    
    public void run() {
        System.out.println(Thread.currentThread().getName() + " doing something");
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(Thread.currentThread().getName() + " finish");
        countDownLatch.countDown();
    }
}

public class CountDownLatchDemo {
    public static void main(String[] args) {
        CountDownLatch countDownLatch = new CountDownLatch(2);
        MyThread t1 = new MyThread("t1", countDownLatch);
        MyThread t2 = new MyThread("t2", countDownLatch);
        t1.start();
        t2.start();
        System.out.println("Waiting for t1 thread and t2 thread to finish");
        try {
            countDownLatch.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }            
        System.out.println(Thread.currentThread().getName() + " continue");        
    }
}

```

某次结果：

```
Waiting for t1 thread and t2 thread to finish
t1 doing something
t2 doing something
t1 finish
t2 finish
main continue
```

本程序首先计数器初始化为2。根据结果，可能会存在如下的一种时序图。

![img](https://pdai.tech/_images/thread/java-thread-x-countdownlatch-3.png)

说明: 首先main线程会调用await操作，此时main线程会被阻塞，等待被唤醒，之后t1线程执行了countDown操作，最后，t2线程执行了countDown操作，此时main线程就被唤醒了，可以继续运行。

### 核心函数 - countDown函数

此函数将递减锁存器的计数，如果计数到达零，则释放所有等待的线程

```java
public void countDown() {
    sync.releaseShared(1);
}

```



### 面试题1

> 实现一个容器，提供两个方法，add，size 写两个线程，线程1添加10个元素到容器中，线程2实现监控元素的个数，当个数到5个时，线程2给出提示并结束.

#### 使用wait和notify实现

```java
import java.util.ArrayList;
import java.util.List;

/**
 *  必须先让t2先进行启动 使用wait 和 notify 进行相互通讯，wait会释放锁，notify不会释放锁
 */
public class T2 {

 volatile   List list = new ArrayList();

    public void add (int i){
        list.add(i);
    }

    public int getSize(){
        return list.size();
    }

    public static void main(String[] args) {

        T2 t2 = new T2();

        Object lock = new Object();

        new Thread(() -> {
            synchronized(lock){
                System.out.println("t2 启动");
                if(t2.getSize() != 5){
                    try {
                        /**会释放锁*/
                        lock.wait();
                        System.out.println("t2 结束");
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
                lock.notify();
            }
        },"t2").start();

        new Thread(() -> {
           synchronized (lock){
               System.out.println("t1 启动");
               for (int i=0;i<9;i++){
                   t2.add(i);
                   System.out.println("add"+i);
                   if(t2.getSize() == 5){
                       /**不会释放锁*/
                       lock.notify();
                       try {
                           lock.wait();
                       } catch (InterruptedException e) {
                           e.printStackTrace();
                       }
                   }
               }
           }
        }).start();
    }
}




t2 启动
t1 启动
add0
add1
add2
add3
add4
t2 结束
add5
add6
add7
add8

```

#### CountDownLatch实现

说出使用CountDownLatch 代替wait notify 好处?





```java
/**
 * 使用CountDownLatch 代替wait notify 好处是通讯方式简单，不涉及锁定  Count 值为0时当前线程继续执行，
 */
public class Test {

    volatile List list = new ArrayList();

    public void add(int i){
        list.add(i);
    }

    public int getSize(){
        return list.size();
    }


    public static void main(String[] args) {
        Test t = new Test();
        CountDownLatch countDownLatch = new CountDownLatch(1);

        new Thread(() -> {
            System.out.println("t2 start");
            if(t.getSize() != 5){
                try {
                    countDownLatch.await();
                    System.out.println("t2 end");
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        },"t2").start();

        new Thread(()->{
            System.out.println("t1 start");
            for (int i = 0;i<9;i++){
                t.add(i);
                System.out.println("add"+ i);
                if(t.getSize() == 5){
                    System.out.println("countdown is open");
                    countDownLatch.countDown();
                }
            }
            System.out.println("t1 end");
        },"t1").start();
    }

}




t2 start
t1 start
add0
add1
add2
add3
add4
countdown is open
add5
add6
add7
add8
t1 end
t2 end
```





# JUC工具类: CyclicBarrier详解

CyclicBarrier底层是基于ReentrantLock和AbstractQueuedSynchronizer来实现的, 在理解的时候最好和CountDownLatch放在一起理解

### 面试题：

- 什么是CyclicBarrier?
- CyclicBarrier底层实现原理?
- CountDownLatch和CyclicBarrier对比?
- CyclicBarrier的核心函数有哪些?
- CyclicBarrier适用于什么场景?

### CyclicBarrier

对于CountDownLatch，其他线程为游戏玩家，比如英雄联盟，主线程为控制游戏开始的线程。在所有的玩家都准备好之前，主线程是处于等待状态的，也就是游戏不能开始。当所有的玩家准备好之后，下一步的动作实施者为主线程，即开始游戏。

对于CyclicBarrier，假设有一家公司要全体员工进行团建活动，活动内容为翻越三个障碍物，每一个人翻越障碍物所用的时间是不一样的。但是公司要求所有人在翻越当前障碍物之后再开始翻越下一个障碍物，也就是所有人翻越第一个障碍物之后，才开始翻越第二个，以此类推。类比地，每一个员工都是一个“其他线程”。当所有人都翻越的所有的障碍物之后，程序才结束。而主线程可能早就结束了，这里我们不用管主线程。

### 和CountDonwLatch再对比

- CountDownLatch减计数，CyclicBarrier加计数。
- CountDownLatch是一次性的，CyclicBarrier可以重用。
- CountDownLatch和CyclicBarrier都有让多个线程等待同步然后再开始下一步动作的意思，但是CountDownLatch的下一步的动作实施者是主线程，具有不可重复性；而CyclicBarrier的下一步动作实施者还是“其他线程”本身，具有往复多次实施动作的特点。

# JUC工具类: Semaphore详解

Semaphore底层是基于AbstractQueuedSynchronizer来实现的。

Semaphore称为计数信号量，它允许n个任务同时访问某个资源，可以将信号量看做是在向外分发使用资源的许可证，只有成功获取许可证，才能使用资源。

### Semaphore示例

```java
import java.util.concurrent.Semaphore;

class MyThread extends Thread {
    private Semaphore semaphore;
    
    public MyThread(String name, Semaphore semaphore) {
        super(name);
        this.semaphore = semaphore;
    }
    
    public void run() {        
        int count = 3;
        System.out.println(Thread.currentThread().getName() + " trying to acquire");
        try {
            semaphore.acquire(count);
            System.out.println(Thread.currentThread().getName() + " acquire successfully");
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            semaphore.release(count);
            System.out.println(Thread.currentThread().getName() + " release successfully");
        }
    }
}

public class SemaphoreDemo {
    public final static int SEM_SIZE = 10;
    
    public static void main(String[] args) {
        Semaphore semaphore = new Semaphore(SEM_SIZE);
        MyThread t1 = new MyThread("t1", semaphore);
        MyThread t2 = new MyThread("t2", semaphore);
        t1.start();
        t2.start();
        int permits = 5;
        System.out.println(Thread.currentThread().getName() + " trying to acquire");
        try {
            semaphore.acquire(permits);
            System.out.println(Thread.currentThread().getName() + " acquire successfully");
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            semaphore.release();
            System.out.println(Thread.currentThread().getName() + " release successfully");
        }      
    }
}



main trying to acquire
main acquire successfully
t1 trying to acquire
t1 acquire successfully
t2 trying to acquire
t1 release successfully
main release successfully
t2 acquire successfully
t2 release successfully

```



### 面试题

- 什么是Semaphore?
- Semaphore内部原理?
- Semaphore常用方法有哪些? 如何实现线程同步和互斥的?
- Semaphore适合用在什么场景?
- 单独使用Semaphore是不会使用到AQS的条件队列?
- Semaphore中申请令牌(acquire)、释放令牌(release)的实现?
- Semaphore初始化有10个令牌，11个线程同时各调用1次acquire方法，会发生什么?
- Semaphore初始化有10个令牌，一个线程重复调用11次acquire方法，会发生什么?
- Semaphore初始化有1个令牌，1个线程调用一次acquire方法，然后调用两次release方法，之后另外一个线程调用acquire(2)方法，此线程能够获取到足够的令牌并继续运行吗?
- Semaphore初始化有2个令牌，一个线程调用1次release方法，然后一次性获取3个令牌，会获取到吗?





semaphore初始化有10个令牌，11个线程同时各调用1次acquire方法，会发生什么?

答案：拿不到令牌的线程阻塞，不会继续往下运行。

semaphore初始化有10个令牌，一个线程重复调用11次acquire方法，会发生什么?

答案：线程阻塞，不会继续往下运行。可能你会考虑类似于锁的重入的问题，很好，但是，令牌没有重入的概念。你只要调用一次acquire方法，就需要有一个令牌才能继续运行

semaphore初始化有1个令牌，1个线程调用一次acquire方法，然后调用两次release方法，之后另外一个线程调用acquire(2)方法，此线程能够获取到足够的令牌并继续运行吗?

答案：能，原因是release方法会添加令牌，并不会以初始化的大小为准。

semaphore初始化有2个令牌，一个线程调用1次release方法，然后一次性获取3个令牌，会获取到吗?

答案：能，原因是release会添加令牌，并不会以初始化的大小为准。Semaphore中release方法的调用并没有限制要在acquire后调用。

# JUC工具类: Phaser详解

Phaser是JDK 7新增的一个同步辅助类，它可以实现CyclicBarrier和CountDownLatch类似的功能，而且它支持对任务的动态调整，并支持分层结构来达到更高的吞吐量。

![img](https://pdai.tech/_images/thread/java-thread-x-juc-phaser-1.png)

# JUC工具类: Exchanger详解

Exchanger是用于线程协作的工具类, 主要用于两个线程之间的数据交换。

Exchanger用于进行两个线程之间的数据交换。它提供一个同步点，在这个同步点，两个线程可以交换彼此的数据。这两个线程通过exchange()方法交换数据，当一个线程先执行exchange()方法后，它会一直等待第二个线程也执行exchange()方法，当这两个线程到达同步点时，这两个线程就可以交换数据了

### 例子

来一个非常经典的并发问题：你有相同的数据buffer，一个或多个数据生产者，和一个或多个数据消费者。只是Exchange类只能同步2个线程，所以你只能在你的生产者和消费者问题中只有一个生产者和一个消费者时使用这个类。

```java
public class Test {
    static class Producer extends Thread {
        private Exchanger<Integer> exchanger;
        private static int data = 0;
        Producer(String name, Exchanger<Integer> exchanger) {
            super("Producer-" + name);
            this.exchanger = exchanger;
        }

        @Override
        public void run() {
            for (int i=1; i<5; i++) {
                try {
                    TimeUnit.SECONDS.sleep(1);
                    data = i;
                    System.out.println(getName()+" 交换前:" + data);
                    data = exchanger.exchange(data);
                    System.out.println(getName()+" 交换后:" + data);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    static class Consumer extends Thread {
        private Exchanger<Integer> exchanger;
        private static int data = 0;
        Consumer(String name, Exchanger<Integer> exchanger) {
            super("Consumer-" + name);
            this.exchanger = exchanger;
        }

        @Override
        public void run() {
            while (true) {
                data = 0;
                System.out.println(getName()+" 交换前:" + data);
                try {
                    TimeUnit.SECONDS.sleep(1);
                    data = exchanger.exchange(data);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(getName()+" 交换后:" + data);
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
        Exchanger<Integer> exchanger = new Exchanger<Integer>();
        new Producer("", exchanger).start();
        new Consumer("", exchanger).start();
        TimeUnit.SECONDS.sleep(7);
        System.exit(-1);
    }
}

Consumer- 交换前:0
Producer- 交换前:1
Consumer- 交换后:1
Consumer- 交换前:0
Producer- 交换后:0
Producer- 交换前:2
Producer- 交换后:0
Consumer- 交换后:2
Consumer- 交换前:0
Producer- 交换前:3
Producer- 交换后:0
Consumer- 交换后:3
Consumer- 交换前:0
Producer- 交换前:4
Producer- 交换后:0
Consumer- 交换后:4
Consumer- 交换前:0

```



### 面试题

- Exchanger主要解决什么问题?
- 对比SynchronousQueue，为什么说Exchanger可被视为 SynchronousQueue 的双向形式?
- Exchanger在不同的JDK版本中实现有什么差别?
- Exchanger实现机制?
- Exchanger已经有了slot单节点，为什么会加入arena node数组? 什么时候会用到数组?
- arena可以确保不同的slot在arena中是不会相冲突的，那么是怎么保证的呢?
- 什么是伪共享，Exchanger中如何体现的?
- Exchanger实现举例





# Reference

https://pdai.tech/md/java/thread/java-thread-x-juc-tool-countdownlatch.html

https://pdai.tech/md/java/thread/java-thread-x-juc-tool-cyclicbarrier.html

https://pdai.tech/md/java/thread/java-thread-x-juc-tool-semaphore.html

https://pdai.tech/md/java/thread/java-thread-x-juc-tool-phaser.html

https://pdai.tech/md/java/thread/java-thread-x-juc-tool-exchanger.html

