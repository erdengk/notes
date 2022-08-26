# ArrayList



![在这里插入图片描述](https://img-blog.csdnimg.cn/684baaf17afc409bae988dbee5a8b104.png)



```java
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable
```

1. 实现了 `RandomAccess` 接口，用索引进行增删改查的数据结构，需要实现随机访问接口。
2. 迭代器效率低于for循环，非RandomAccess 接口（LinkedList）建议使用迭代器。
3. `Cloneable`   接口，ArrayList 支持浅拷贝
4. `Serializable` 可以被序列化

> 讲讲深浅拷贝

## 相关属性

默认容量，不指定容量时默认为10.

```java
private static final int DEFAULT_CAPACITY = 10;
```

初始容量为0时，使用的object数组

```java
private static final Object[] EMPTY_ELEMENTDATA = {};
```

默认容量为10时，使用的object数组

```java
private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};
```

> 为什么要准备两个空数组？

`transient`  修饰的元素，不能被序列化 ，

```java
transient Object[] elementData;
```

> 讲讲transient关键字？

arralyList 的元素数量，不是elementData数组的长度

```java
private int size;
```





## 初始化

### 构造器

```java
    public ArrayList() {
        this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
    }
		public ArrayList(int initialCapacity) {
      if (initialCapacity > 0) {
          this.elementData = new Object[initialCapacity];
      } else if (initialCapacity == 0) {
        // 传入 0 时，走这个if 
          this.elementData = EMPTY_ELEMENTDATA;
      } else {
          throw new IllegalArgumentException("Illegal Capacity: "+
                                             initialCapacity);
      }
	}
    public ArrayList(Collection<? extends E> c) {
        Object[] a = c.toArray();
        if ((size = a.length) != 0) {
            if (c.getClass() == ArrayList.class) {
                elementData = a;
            } else {
                elementData = Arrays.copyOf(a, size, Object[].class);
            }
        } else {
            // replace with empty array.
            elementData = EMPTY_ELEMENTDATA;
        }
    }
```



### Arrays.asList

```java
List<String> list1 = Arrays.asList();
list1.add("a");
```

` Arrays` 没有复写AbstractList的add方法，是直接调用 AbstractList 中的add方法。

```java
public boolean add(E e) {
    add(size(), e);
    return true;
}
public void add(int index, E element) {
    throw new UnsupportedOperationException();
}
```

会抛出 `UnsupportedOperationException`   异常

```java
Exception in thread "main" java.lang.UnsupportedOperationException
	at java.util.AbstractList.add(AbstractList.java:148)
	at java.util.AbstractList.add(AbstractList.java:108)
	at analyse.ArrayListAnalyse.main(ArrayListAnalyse.java:51)
```

> Arrays.asList() 的使用场景是？



### Collections.emptyList

```java
List<String> list2 = Collections.emptyList();
list2.add("a");
```

```java
    public static final <T> List<T> emptyList() {
        return (List<T>) EMPTY_LIST;
    }
    public static final List EMPTY_LIST = new EmptyList<>();
    private static class EmptyList<E>
        extends AbstractList<E>
        implements RandomAccess, Serializable
```

没有覆写add方法 

Exception in thread "main" java.lang.UnsupportedOperationException

> Collections.emptyList() 使用场景？



## 添加元素 & 扩容

### 扩容问题

下面代码扩容了几次？👇

```java
        List<String> list = new ArrayList<>(0);
        // 添加了10个元素
        list.add("a");
        list.add("a");
        list.add("a");
        list.add("a");
        list.add("a");
        list.add("a");
        list.add("a");
        list.add("a");
        list.add("a");
        list.add("a");
```



### add(E e) 

```java
public boolean add(E e) {
    ensureCapacityInternal(size + 1);  // Increments modCount!!
    elementData[size++] = e;
    return true;
}
```

`ensureCapacityInternal` 确保容量是合法的

```java
    private static int calculateCapacity(Object[] elementData, int minCapacity) {
        if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
          // 此例中，不会走到这个分支中，因为elementData 是 EMPTY_ELEMENTDATA
          // 所以不会 取到默认容量 10 
            return Math.max(DEFAULT_CAPACITY, minCapacity);
        }
        return minCapacity;
    }

    private void ensureCapacityInternal(int minCapacity) {
        ensureExplicitCapacity(calculateCapacity(elementData, minCapacity));
      // 执行完毕后会进入下方的方法内
    }

    private void ensureExplicitCapacity(int minCapacity) {
        modCount++;

        // overflow-conscious code
        if (minCapacity - elementData.length > 0)
          // 执行扩容方法
            grow(minCapacity);
    }
```

```java
private void grow(int minCapacity) {
    // overflow-conscious code
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + (oldCapacity >> 1);
  // 近似1.5倍，3 + 3>>1  = 3 + 1.5 = 4.5 (下取整) = 4
  
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    if (newCapacity - MAX_ARRAY_SIZE > 0)
      //MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8 
      // 比MAX_ARRAY_SIZE 还大时，会尝试使用 Integer.MAX_VALUE
        newCapacity = hugeCapacity(minCapacity);
  
    // minCapacity is usually close to size, so this is a win:
    elementData = Arrays.copyOf(elementData, newCapacity);
}
    private static int hugeCapacity(int minCapacity) {
        if (minCapacity < 0) // overflow
            throw new OutOfMemoryError();
        return (minCapacity > MAX_ARRAY_SIZE) ?
            Integer.MAX_VALUE :
            MAX_ARRAY_SIZE;
    }
```

###  add(int index, E element)

```java
    public void add(int index, E element) {
      // 检查是否越界
        rangeCheckForAdd(index);
      // 检查是否需要扩容
        ensureCapacityInternal(size + 1);  // Increments modCount!!
        System.arraycopy(elementData, index, elementData, index + 1,
                         size - index);
        elementData[index] = element;
        size++;
    }
```

System.arraycopy();

list 如果在list前面或者中间进行add操作时会导致底层数组在内存上的移动，增加时间开销。

`Arrays.copyOf(elementData, newCapacity)`  是一个浅拷贝操作

```java
    public static <T> T[] copyOf(T[] original, int newLength) {
        return (T[]) copyOf(original, newLength, original.getClass());
    }
    
        public static <T,U> T[] copyOf(U[] original, int newLength, Class<? extends T[]> newType) {
        @SuppressWarnings("unchecked")
        T[] copy = ((Object)newType == (Object)Object[].class)
            ? (T[]) new Object[newLength]
            : (T[]) Array.newInstance(newType.getComponentType(), newLength);
          // 
        System.arraycopy(original, 0, copy, 0,
                         Math.min(original.length, newLength));
        return copy;
    }
```



### addAll(Collection<? extends E> c)

```java
public boolean addAll(Collection<? extends E> c) {
    Object[] a = c.toArray();
    int numNew = a.length;
    ensureCapacityInternal(size + numNew);  // Increments modCount
    System.arraycopy(a, 0, elementData, size, numNew);
    size += numNew;
    return numNew != 0;
}    
public boolean addAll(int index, Collection<? extends E> c) {
        rangeCheckForAdd(index);

        Object[] a = c.toArray();
        int numNew = a.length;
        ensureCapacityInternal(size + numNew);  // Increments modCount

        int numMoved = size - index;
        if (numMoved > 0)
            System.arraycopy(elementData, index, elementData, index + numNew,numMoved);

        System.arraycopy(a, 0, elementData, index, numNew);
        size += numNew;
        return numNew != 0;
    }

    private void rangeCheckForAdd(int index) {
      // 检查 index 的合法性 把可能性大的放前面 对整体性能会有提升
        if (index > size || index < 0)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
    }
```

返回值有歧义。

对于代码里面中间的list变量，我们需要明白它里面是否有元素



```java
        List<String> list6 = new ArrayList<>();
        List<String> list7 = new ArrayList<>();
        // 输出的是？
        System.out.println(list6.addAll(list7));
```



## clone()

arraylist 中拷贝出来的对象修改次数会被修改为0

```java
public Object clone() {
    try {
        ArrayList<?> v = (ArrayList<?>) super.clone();
        v.elementData = Arrays.copyOf(elementData, size);
      // 拷贝出来的对象 修改次数要被修改为0
        v.modCount = 0;
        return v;
    } catch (CloneNotSupportedException e) {
        // this shouldn't happen, since we are Cloneable
        throw new InternalError(e);
    }
}
```



## 更新、获取元素

```java
public E get(int index) {
  // 先进行范围的检查
    rangeCheck(index);

    return elementData(index);
}

    private void rangeCheck(int index) {
        if (index >= size)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
    }

    public E set(int index, E element) {
        rangeCheck(index);

        E oldValue = elementData(index);
        elementData[index] = element;
        return oldValue;
    }
```

```java
        List<String> list4 = new ArrayList<>();
        list.add("a");
        System.out.println(list.set(0,"b"));



    public E set(int index, E element) {
        rangeCheck(index);

        E oldValue = elementData(index);
        elementData[index] = element;
        return oldValue;
    }
```

`set` 操作中，返回的是 `oldValue`

 

### retainAll(Collection c)

求两个集合是否有交集，使用之后会将原list 中与传入集合中`相同的元素`删除。

```java
 public boolean retainAll(Collection<?> c) {
   //判断集合是否为null
        Objects.requireNonNull(c);
   // 传入true，表示 删除C中没有包含A的元素 
        return batchRemove(c, true);
    }
/**
complement 表示 删除C中没有包含A的元素 
*/
    private boolean batchRemove(Collection<?> c, boolean complement) {
        final Object[] elementData = this.elementData;
        int r = 0, w = 0;
        boolean modified = false;
        try {
           
// 遍历整个数组，如果c中包含该元素，则把该元素放到写指针的位置
            for (; r < size; r++)
                if (c.contains(elementData[r]) == complement)
                    elementData[w++] = elementData[r];
        } finally {
            // Preserve behavioral compatibility with AbstractCollection,
            // even if c.contains() throws.
            if (r != size) {
// 如果c.contains()抛出了异常，则把未读的元素都拷贝到写指针之后
                System.arraycopy(elementData, r,
                                 elementData, w,
                                 size - r);
                w += size - r;
            }
            if (w != size) {
                // clear to let GC do its work
// 将写指针之后的元素置为空，帮助GC
                for (int i = w; i < size; i++)
                    elementData[i] = null;
                modCount += size - w;
                size = w;
                modified = true;
            }
        }
        return modified;
    }
```

> （1）遍历elementData数组；
>
> （2）如果元素在c中，则把这个元素添加到elementData数组的w位置并将w位置往后移一位；
>
> （3）遍历完之后，w之前的元素都是两者共有的，w之后（包含）的元素不是两者共有的；
>
> （4）将w之后（包含）的元素置为null，方便GC回收；

测试例子

```
        // 例子 8
        List<String>  list9 = new ArrayList();
        list9.add("1");
        list9.add("2");
        list9.add("3");
        List<String>  list10 = new ArrayList();
        list10.add("1");
        list10.add("2");
        System.out.println(list9.retainAll(list10));
        System.out.println(Arrays.toString(list9.toArray()));
        System.out.println(Arrays.toString(list10.toArray()));
        /**
         * true
         * [1, 2]
         * [1, 2]
         */
```

## 删除元素

### remove()

```java
public E remove(int index) {
    rangeCheck(index);

    modCount++;
    E oldValue = elementData(index);

    int numMoved = size - index - 1;
    if (numMoved > 0)
        System.arraycopy(elementData, index+1, elementData, index,
                         numMoved);
  // 对象不可达，触发垃圾回收
    elementData[--size] = null; // clear to let GC do its work

    return oldValue;
}
```

返回的是remove的元素

```java
    public boolean remove(Object o) {
        if (o == null) {
            for (int index = 0; index < size; index++)
                if (elementData[index] == null) {
                    fastRemove(index);
                    return true;
                }
        } else {
            for (int index = 0; index < size; index++)
                if (o.equals(elementData[index])) {
                    fastRemove(index);
                    return true;
                }
        }
        return false;
    }

private void fastRemove(int index) {
        modCount++;
        int numMoved = size - index - 1;
        if (numMoved > 0)
            System.arraycopy(elementData, index+1, elementData, index,
                             numMoved);
        elementData[--size] = null; // clear to let GC do its work
    }
```

避免`fastRemove`的代码在`remove`中重复书写，所以抽离出一个新的方法，并非真的`fast-remove`

### removeRange

```java
protected void removeRange(int fromIndex, int toIndex) {
    modCount++;
    int numMoved = size - toIndex;
    System.arraycopy(elementData, toIndex, elementData, fromIndex,
                     numMoved);

    // clear to let GC do its work
    int newSize = size - (toIndex-fromIndex);
    for (int i = newSize; i < size; i++) {
        elementData[i] = null;
    }
    size = newSize;
}
```

> removeRange(int fromIndex, int toIndex)  开头和结尾的元素是否被删除？

开头不被删，结尾的会被删

### removeAll

```java
    public boolean removeAll(Collection<?> c) {
        Objects.requireNonNull(c);
        return batchRemove(c, false);
    }

    public static <T> T requireNonNull(T obj) {
        if (obj == null)
            throw new NullPointerException();
        return obj;
    }
```

只判断了null，没判断空，可以removeAll 一个空的list（错误操作❌）



### clear()

```java
public void clear() {
    modCount++;

    // clear to let GC do its work
    for (int i = 0; i < size; i++)
        elementData[i] = null;

    size = 0;
}
```

逐个设置为null，造成对象不可达，引起GC回收。

```java
        List<String> list5 = new ArrayList<>();
        list5.add("1");
        list5.clear();
        list5.add("1");
        // 扩容几次？
```

`clear `没有重置list的size，所以list底层数组的size还是原来的size，如果重新添加元素，不会再次扩容。

**当我们需要对一个list重复利用的话，一定要选择list.claer()**



错误示范：

```java
 List<String> list5 = new ArrayList<>();
 list5 = new ArrayList<>();
```

再次添加元素时会继续扩容。



## 序列化问题

> 序列化是什么？为什么要序列化？

### readObject & writeObject

```java
 private void writeObject(java.io.ObjectOutputStream s)
        throws java.io.IOException{
        // 记录修改次数，防止其他线程修改
        int expectedModCount = modCount;
        s.defaultWriteObject();

        s.writeInt(size);

        for (int i=0; i<size; i++) {
            s.writeObject(elementData[i]);
        }
// 如果不一致 抛出修改异常
        if (modCount != expectedModCount) {
            throw new ConcurrentModificationException();
        }
    }

    /**
     * Reconstitute the <tt>ArrayList</tt> instance from a stream (that is,
     * deserialize it).
     */
    private void readObject(java.io.ObjectInputStream s)
        throws java.io.IOException, ClassNotFoundException {
        elementData = EMPTY_ELEMENTDATA;

        // Read in size, and any hidden stuff
        s.defaultReadObject();

        // Read in capacity
        s.readInt(); 

        if (size > 0) {
            // 计算容量
            int capacity = calculateCapacity(elementData, size);
            SharedSecrets.getJavaOISAccess().checkArray(s, Object[].class, capacity);
          // 检查是否需要扩容
            ensureCapacityInternal(size);

            Object[] a = elementData;
            // Read in all elements in the proper order.
            for (int i=0; i<size; i++) {
                a[i] = s.readObject();
            }
        }
    }
```

为什么用 transient 修饰 elementData ？

```java
        /*
        发送list给server端（过网络）
        list 序列化 （writeObject）
           transient Object[] elementData
        server 端接收到list
        list 反序列化 （readObject）
         */
```

假如有1w个元素，则 list size 大约为1.5w
如果直接序列化 elementData 数组
则会有5k个空元素序列化
所以使用for 循环逐个遍历list中的元素，

优点
1. 避免浪费序列化次数
2. 不需要考虑null序列化问题





### 参考

[死磕 Java集合之ArrayList源码分析](https://mp.weixin.qq.com/s?__biz=MzkxNDEyOTI0OQ==&mid=2247484476&idx=1&sn=dcf80bee7a238da3033b1dbcb4e17c6d&chksm=c1726c32f605e524dfe4c1a591920552aded31b567833f4ac0c91848ac6a2440b7f1469339ec&scene=178&cur_album_id=1538024362992254978#rd)
