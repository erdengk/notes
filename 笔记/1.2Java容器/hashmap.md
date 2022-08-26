# HashMap
**部分图片来源网上，非自己总结，侵删**



基于jdk1.7

内部存储结构为，数组+链表
hashMap使用拉链法来解决冲突
内部包含了一个 Entry 类型的数组 table。Entry 存储着键值对。它包含了四个字段，从 next 字段可以看出 Entry 是一个链表.


```
transient Entry[] table;
```
``` java

static class Entry<K,V> implements Map.Entry<K,V> {
    final K key;
    V value;
    Entry<K,V> next;
    int hash;

    Entry(int h, K k, V v, Entry<K,V> n) {
        value = v;
        next = n;
        key = k;
        hash = h;
    }

    public final K getKey() {
        return key;
    }

    public final V getValue() {
        return value;
    }

    public final V setValue(V newValue) {
        V oldValue = value;
        value = newValue;
        return oldValue;
    }

    public final boolean equals(Object o) {
        if (!(o instanceof Map.Entry))
            return false;
        Map.Entry e = (Map.Entry)o;
        Object k1 = getKey();
        Object k2 = e.getKey();
        if (k1 == k2 || (k1 != null && k1.equals(k2))) {
            Object v1 = getValue();
            Object v2 = e.getValue();
            if (v1 == v2 || (v1 != null && v1.equals(v2)))
                return true;
        }
        return false;
    }

    public final int hashCode() {
        return Objects.hashCode(getKey()) ^ Objects.hashCode(getValue());
    }

    public final String toString() {
        return getKey() + "=" + getValue();
    }
}
```

::当hash冲突后，新的元素要被插在链表头部::

newNode---》oldNode





![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b366cfad49a54b4b89e44734cdb86d1f~tplv-k3u1fbpfcp-watermark.awebp)





## 1.put操作

```java

public V put(K key, V value) {
    if (table == EMPTY_TABLE) {
        inflateTable(threshold);
    }
    // 键为 null 单独处理
    if (key == null)
        return putForNullKey(value);
    int hash = hash(key);
    // 确定桶下标
    int i = indexFor(hash, table.length);
    // 先找出是否已经存在键为 key 的键值对，如果存在的话就更新这个键值对的值为 value
    for (Entry<K,V> e = table[i]; e != null; e = e.next) {
        Object k;
        if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
            V oldValue = e.value;
            e.value = value;
            e.recordAccess(this);
            return oldValue;
        }
    }

    modCount++;
    // 插入新键值对
    addEntry(hash, key, value, i);
    return null;
}

```

hash值的函数也要关注一下，它称之为“扰动函数”，

**扰动函数**就是为了解决hash碰撞的。它会综合hash值高位和低位的特征，并存放在低位，因此在与运算时，相当于高低位一起参与了运算，以减少hash碰撞的概率。（在JDK8之前，扰动函数会扰动四次，JDK8简化了这个操作）

```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

关于inflateTable方法

```java
   //初始化HashMap
    private void inflateTable(int toSize) {
        //计算出大于toSize最临近的2的N此方的值
    //假设此处传入6, 那么最临近的值为2的3次方，也就是8
        int capacity = roundUpToPowerOf2(toSize);
    //由此处可知：threshold = capacity * loadFactor
        threshold = (int) Math.min(capacity * loadFactor, MAXIMUM_CAPACITY + 1);
    //创建Entry数组，这个Entry数组就是HashMap所谓的容器
        table = new Entry[capacity];
        initHashSeedAsNeeded(capacity);
}
```

HashMap 允许插入键为 null 的键值对。但是因为无法调用 null 的 hashCode() 方法，也就无法确定该键值对的桶下标，只能通过强制指定一个桶下标来存放。HashMap 使用第 0 个桶存放键为 null 的键值对。
```java
private V putForNullKey(V value) {
    for (Entry<K,V> e = table[0]; e != null; e = e.next) {
        if (e.key == null) {
            V oldValue = e.value;
            e.value = value;
            e.recordAccess(this);
            return oldValue;
        }
    }
    modCount++;
    addEntry(0, null, value, 0);
    return null;
}
```



只会往表中插入 key-value, 若key对应的value之前存在，不会覆盖。（jdk8增加的方法）

```java
    @Override
    public V putIfAbsent(K key, V value) {
        return putVal(hash(key), key, value, true, true);
    }
```









## 2.确定下标



```
int hash = hash(key);
int i = indexFor(hash, table.length);

final int hash(Object k) {
    int h = hashSeed;
    if (0 != h && k instanceof String) {
        return sun.misc.Hashing.stringHash32((String) k);
    }

    h ^= k.hashCode();

    // This function ensures that hashCodes that differ only by
    // constant multiples at each bit position have a bounded
    // number of collisions (approximately 8 at default load factor).
    h ^= (h >>> 20) ^ (h >>> 12);
    return h ^ (h >>> 7) ^ (h >>> 4);
}

```



```
static int indexFor(int h, int length) {
    return h & (length-1);
}
```


>为什么是 h & length-1 ？


HashMap的初始容量和扩容都是以2的次方来进行的，那么length-1换算成二进制的话肯定所有位都为1，就比如2的3次方为8，length-1的二进制表示就是111， 而按位与计算的原则是两位同时为“1”，结果才为“1”，否则为“0”。所以h& (length-1)运算从数值上来讲其实等价于对length取模，也就是h%length。
只有当数组长度为2的n次方时，不同的key计算得出的index索引相同的几率才会较小，数据在数组上分布也比较均匀，碰撞的几率也小，相对的，查询的时候就不用遍历某个位置上的链表，这样查询效率也就较高了。
[HashMap中的indexFor方法分析 ](https://blog.csdn.net/j1231230/article/details/78072115)


令 x = 1<<4，即 x 为 2 的 4 次方，它具有以下性质：
x    : 00010000
x-1 : 00001111

令一个数 y 与 x-1 做与运算，可以去除 y 位级表示的第 4 位以上数：
y           : 10110010
x-1        : 00001111
y&(x-1) : 00000010

这个性质和 y 对 x 取模效果是一样的：
y   : 10110010
x   : 00010000
y%x : 00000010

::巧妙的使用位运算来代替模运算提高计算速度::





**在java8之后，都是所用尾部插入了。**[参考](https://mp.weixin.qq.com/s/0Gf2DzuzgEx0i3mHVvhKNQ)



##### 为什么后来改为尾部插入呢？

首先需要讲一下hashMap 的扩容机制

分为两步

- 扩容：创建一个新的Entry空数组，长度是原数组的2倍。
- ReHash：遍历原Entry数组，把所有的Entry重新Hash到新数组。

##### 为什么不复制，而是需要重新Hash？

是因为长度扩大以后，Hash的规则也随之改变。

index = HashCode（Key） & （Length - 1）

在重新hash的过程中，多线程操作hashmap 时，

一部分的值已经操作完成，但有一部分的值还没有操作完成，此时hashmap进行了扩容操作

全部完全操作后可能会导致环形链表

**使用头插会改变链表的上的顺序，但是如果使用尾插，在扩容时会保持链表元素原本的顺序，就不会出现链表成环的问题了。**



Java7在多线程操作HashMap时可能引起死循环，原因是扩容转移后前后链表顺序倒置，在转移过程中修改了原来链表中节点的引用关系。

Java8在同样的前提下并不会引起死循环，原因是扩容转移后前后链表顺序不变，保持之前节点的引用关系。



##### 那是不是意味着Java8就可以把HashMap用在多线程中呢？

我认为即使不会出现死循环，但是通过源码看到put/get方法都没有加同步锁，多线程情况最容易出现的就是：无法保证上一秒put的值，下一秒get的时候还是原值，所以线程安全还是无法保证。





##### 为啥我们重写equals方法的时候需要重写hashCode方法呢？

因为在java中，所有的对象都是继承于Object类。Ojbect类中有两个方法equals、hashCode，这两个方法都是用来比较两个对象是否相等的。

在未重写equals方法我们是继承了object的equals方法，**那里的 equals是比较两个对象的内存地址**，显然我们new了2个对象内存地址肯定不一样

- 对于值对象，==比较的是两个对象的值
- 对于引用对象，比较的是两个对象的地址

大家是否还记得我说的HashMap是通过key的hashCode去寻找index的，那index一样就形成链表了，也就是说”12“和”21“的index都可能是2，在一个链表上的。

我们去get的时候，他就是根据key去hash然后计算出index，找到了2，那我怎么找到具体的”12“还是”21“呢？

**equals**！是的，所以如果我们对equals方法进行了重写，建议一定要对hashCode方法重写，以保证相同的对象返回相同的hash值，不同的对象返回不同的hash值。

不然一个链表的对象，你哪里知道你要找的是哪个，到时候发现hashCode都一样，就无法满足要求。





## 3.扩容-基本原理
设 HashMap 的 table 长度为 M，需要存储的键值对数量为 N，如果哈希函数满足均匀性的要求，那么每条链表的长度大约为 N/M，因此查找的复杂度为 O(N/M)。

为了让查找的成本降低，应该使 N/M 尽可能小，因此需要保证 M 尽可能大，也就是说 table 要尽可能大。HashMap 采用动态扩容来根据当前的 N 值来调整 M 值，使得空间效率和时间效率都能得到保证。

和扩容相关的参数主要有：capacity、size、threshold 和 load_factor。
[HashMap其实就那么一回事儿之源码浅析 ](https://www.cnblogs.com/dongying/p/4022795.html)

capacity	
	table 的容量大小，默认为 16。需要注意的是 capacity 必须保证为 2 的 n 次方。
size	
	键值对数量。
threshold
		size 的临界值，当 size 大于等于 threshold 就必须进行扩容操作。
loadFactor
		装载因子，table 能够使用的比例，threshold = (int)(capacity* loadFactor)。

**loadFactor是装载因子，表示HashMap满的程度，默认值为0.75f，设置成0.75有一个好处，那就是0.75正好是3/4，而capacity又是2的幂。所以，两个数的乘积都是整数。对于一个默认的HashMap来说，默认情况下，当其size大于12(16*0.75)时就会触发扩容。**



当需要扩容时，令 capacity 为原来的两倍。
```
void addEntry(int hash, K key, V value, int bucketIndex) {
    Entry<K,V> e = table[bucketIndex];
    table[bucketIndex] = new Entry<>(hash, key, value, e);
    if (size++ >= threshold)
        resize(2 * table.length);
}
```






扩容使用 resize() 实现，需要注意的是，扩容操作同样需要把 oldTable 的所有键值对重新插入 newTable 中，因此这一步是很费时的。

```java
void resize(int newCapacity) {
    Entry[] oldTable = table;
    int oldCapacity = oldTable.length;
    if (oldCapacity == MAXIMUM_CAPACITY) {
        threshold = Integer.MAX_VALUE;
        return;
    }
    Entry[] newTable = new Entry[newCapacity];
    transfer(newTable);
    table = newTable;
    threshold = (int)(newCapacity * loadFactor);
}

void transfer(Entry[] newTable) {
    Entry[] src = table;
    int newCapacity = newTable.length;
    for (int j = 0; j < src.length; j++) {
        Entry<K,V> e = src[j];
        if (e != null) {
            src[j] = null;
            do {
                Entry<K,V> next = e.next;
                int i = indexFor(e.hash, newCapacity);
                e.next = newTable[i];
                newTable[i] = e;
                e = next;
            } while (e != null);
        }
    }
}
```

## 4.扩容-重新计算桶下标

在进行扩容时，需要把键值对重新计算桶下标，从而放到对应的桶上。在前面提到，HashMap 使用 hash%capacity 来确定桶下标。HashMap capacity 为 2 的 n 次方这一特点能够极大降低重新计算桶下标操作的复杂度。

取下标 是用 **哈希值 与运算 （桶的长度-1）** `i = (n - 1) & hash`

假设原数组长度 capacity 为 16，扩容之后 new capacity 为 32：

```html
capacity     : 00010000
new capacity : 00100000
```

对于一个 Key，它的哈希值 hash 在第 5 位：

- 为 0，那么 hash%00010000 = hash%00100000，桶位置和原来一致；
- 为 1，hash%00010000 = hash%00100000 + 16，桶位置是原位置 + 16。

利用**哈希值 与运算 旧的容量** ，`if ((e.hash & oldCap) == 0)`,可以得到哈希值去模后，是大于等于oldCap还是小于oldCap，等于0代表小于oldCap，**应该存放在原来的位置，否则存放在扩容后的位置**

## 5.计算数组容量

HashMap 构造函数允许用户传入的容量不是 2 的 n 次方，因为它可以自动地将传入的容量转换为 2 的 n 次方。

先考虑如何求一个数的掩码，对于 10010000，它的掩码为 11111111，可以使用以下方法得到：

```text
mask |= mask >> 1    11011000
mask |= mask >> 2    11111110
mask |= mask >> 4    11111111
```

mask+1 是大于原始数字的最小的 2 的 n 次方。

```text
num     10010000
mask+1 100000000
```

以下是 HashMap 中计算数组容量的代码：

```java
static final int tableSizeFor(int cap) {
    int n = cap - 1;
    n |= n >>> 1;
    n |= n >>> 2;
    n |= n >>> 4;
    n |= n >>> 8;
    n |= n >>> 16;
    return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
}
```

## 6. 链表转红黑树

从 JDK 1.8 开始，一个桶存储的链表长度大于等于 8 时会将链表转换为红黑树。

## 7. 与 Hashtable 的比较

- Hashtable 使用 synchronized 来进行同步。
- HashMap 可以插入键为 null 的 Entry。
- HashMap 的迭代器是 fail-fast 迭代器。
- HashMap 不能保证随着时间的推移 Map 中的元素次序是不变的。
- `HashTable`默认容量是11。
- 扩容时，新容量是原来的2倍+1。`int newCapacity = (oldCapacity << 1) + 1;`
- `Hashtable`是`Dictionary`的子类同时也实现了`Map`接口，`HashMap`是`Map`接口的一个实现类；

## 8.部分方法

### java8新增，带默认值的get方法

以key为条件，找到了返回value。否则返回defaultValue

```
    @Override
    public V getOrDefault(Object key, V defaultValue) {
        Node<K,V> e;
        return (e = getNode(hash(key), key)) == null ? defaultValue : e.value;
    }
```









## 9.总结

1. HashMap只允许一个为null的key。

2. HashMap的扩容：当前table数组的两倍

3. HashMap实际能存储的元素个数： capacity * loadFactor

4. HashMap在扩容的时候，会重新计算hash值，并对hash的位置进行重新排列， **因此，为了效率，尽量给HashMap指定合适的容量，避免多次扩容**









待看：

https://mp.weixin.qq.com/s/VtIpj-uuxFj5Bf6TmTJMTw



## HashMap常见面试题：

##### HashMap的底层数据结构？

##### HashMap的存取原理？

##### Java7和Java8的区别？

##### 为啥会线程不安全？

##### 有什么线程安全的类代替么?

##### 默认初始化大小是多少？为啥是这么多？为啥大小都是2的幂？

##### HashMap的扩容方式？负载因子是多少？为什是这么多？

##### HashMap的主要参数都有哪些？

##### HashMap是怎么处理hash碰撞的？

##### hash的计算规则？



