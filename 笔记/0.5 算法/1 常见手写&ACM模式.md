## 手写快排

快排，时间复杂度 nlogn ，因为分治需要开个栈空间，空间复杂度是 logn

### 普通快排

快速排序是一种基于分而治之的排序算法，其中：
1、通过从数组中选择一个中心元素将数组划分成两个子数组，在划分数组时，将比中心元素小的元素放在左子数组，将比中心元素大的元素放在右子数组。
2、左子数组和右子数组也使用相同的方法进行划分，这个过程一直持续到每个子数组都包含一个元素为止。
3、最后，将元素组合在一起以形成排序的数组。

```java

public class QuickSort {

    public static int partition(int[] array, int low, int high) {
        // 取最后一个元素作为中心元素
        int pivot = array[high];
        // 定义指向比中心元素大的指针，首先指向第一个元素
        int pointer = low;
        // 遍历数组中的所有元素，将比中心元素大的放在右边，比中心元素小的放在左边
        for (int i = low; i < high; i++) {
          //第一处： 
            if (array[i] <= pivot) {
                // 将比中心元素小的元素和指针指向的元素交换位置
                // 如果第一个元素比中心元素小，这里就是自己和自己交换位置，指针和索引都向下一位移动
                // 如果元素比中心元素大，索引向下移动，指针指向这个较大的元素，直到找到比中心元素小的元素，并交换位置，指针向下移动
             		swap( array, i, pointer);
                pointer++;
            }
            System.out.println(Arrays.toString(array));
        }
        // 将中心元素和指针指向的元素交换位置
         swap(array , pointer , high);
        return pointer;
    }

    public static void quickSort(int[] array, int low, int high) {
        if (low < high) {
            // 获取划分子数组的位置
            int position = partition(array, low, high);
            // 左子数组递归调用
            quickSort(array, low, position -1);
            // 右子数组递归调用
            quickSort(array, position + 1, high);
        }
    }

    public static void main(String[] args) {
        int[] array = {6,72,113,11,23};
        quickSort(array, 0, array.length -1);
        System.out.println("排序后的结果");
        System.out.println(Arrays.toString(array));
    }
}

```



第一处：

![img](https://img-blog.csdnimg.cn/img_convert/aeb5f86d9379e75da93bdd6fc95a3d2c.png)



https://blog.csdn.net/qq_39218530/article/details/116998678



```java
class Solution {
    public int[] sortArray(int[] nums) {
        quickSort(nums,0,nums.length - 1);
        return nums;
    }
    public static void quickSort(int[] a,int low, int high){
        if(low > high)
           return;
        int i = low;
        int j = high;
        int temp = a[low];
        while(i!=j){
           while(a[j] >= temp && i < j){
               j--;
           }
          while(a[i] <= temp && i < j){
               i++;
           } 
           if(i < j){
                 int t = a[j];
                 a[j] = a[i];
                 a[i] = t;
           }  
           
        }
        a[low] = a[i];
        a[i] = temp;
        quickSort(a,low,i - 1);
        quickSort(a,i+1,high);  
    }
}
```



### 随机快排

先写快排 然后 说经典快排的缺点，然后简单优化为随机快排

上面版本的快排在选取主元的时候，每次都选取最右边的元素。当序列为有序时，会发现划分出来的两个子序列一个里面没有元素，而另一个则只比原来少一个元素。为了避免这种情况，引入一个随机化量来破坏这种有序状态。

如： 123456 

分治 ： 123456 / 空 

partition 在处理前，加一条随机交换语句

```java
private static int partition(int[] array, int low, int high) {
        swap( array,  high, (int)(Math.random()*( high- low +1) )+low );
        int index = array[high];
        int pointer = low;
        for( int i = low ; i<high ;i++){
            if(array[i] <= index){
                swap( array, i, pointer);
                pointer++;
            }
        }
        swap(array , pointer , high);
        return pointer;
    }
```

### 效率对比

在10w，100w，1000w以内两者效率差不多

但如果是1w，10w，100w，1000w的有序数列

随机快排的效率将远远超过普通快排

## 手写堆排

堆是具有下列性质的完全二叉树：每个结点的值都大于或等于其左右孩子结点的值，称为大顶堆；或者每个结点的值都小于或等于其左右孩子结点的值，称为小顶堆。



```java

```



## 手写LRU

### LRU 算法设计思想

查找和插入的时间复杂度为 O(1)，HashMap 没得跑了，但是 HashMap 是无序的集合，怎么样将其改造为有序集合呢？答案就是在各个 Node 节点之间增加 prev 指针和 next 指针，构成双向链表

![image-20210207184327176](https://img-blog.csdnimg.cn/img_convert/abc068f7d766a68862079499bfea6613.png)

LRU 的算法核心是哈希链表，本质就是 HashMap+DoubleLinkedList 时间复杂度是O(1)，哈希表+双向链表的结合体，下面这幅动图完美诠释了 HashMap+DoubleLinkedList 的工作原理

![image-20210206182454498](https://img-blog.csdnimg.cn/img_convert/174430816d515a4f9070b7a7158dffa6.gif)



### LinkedHashMap实现

```java
/**
 * @ClassName LRUCacheDemo
 * @Description TODO
 * @Author Oneby
 * @Date 2021/2/7 16:26
 * @Version 1.0
 */
public class LRUCacheDemo<K, V> extends LinkedHashMap<K, V> {

    // 缓存容量
    private int capacity;

    public LRUCacheDemo(int capacity) {
        // accessOrder：the ordering mode. true for access-order；false for insertion-order
        super(capacity, 0.75F, true);
        this.capacity = capacity;
    }

    // 用于判断是否需要删除最近最久未使用的节点
    @Override
    protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
        return super.size() > capacity;
    }

    public static void main(String[] args) {
        LRUCacheDemo lruCacheDemo = new LRUCacheDemo(3);

        lruCacheDemo.put(1, "a");
        lruCacheDemo.put(2, "b");
        lruCacheDemo.put(3, "c");
        System.out.println(lruCacheDemo.keySet());

        lruCacheDemo.put(4, "d");
        System.out.println(lruCacheDemo.keySet());

        lruCacheDemo.put(3, "c");
        System.out.println(lruCacheDemo.keySet());
        lruCacheDemo.put(3, "c");
        System.out.println(lruCacheDemo.keySet());
        lruCacheDemo.put(3, "c");
        System.out.println(lruCacheDemo.keySet());
        lruCacheDemo.put(5, "x");
        System.out.println(lruCacheDemo.keySet());
    }

}

```



构造函数中的 accessOrder 字段

在 LRUCacheDemo 的构造方法中，我们调用了 LinkedHashMap 的构造方法，其中有一个字段为 accessOrder

![image-20210207193458904](https://img-blog.csdnimg.cn/img_convert/e2135890194fbd120f88377c16d34b26.png)

accessOrder = true 和 accessOrder = false 的情况

当 accessOrder = true 时，每次使用 key 时（put 或者 get 时），都将 key 对应的数据移动到队尾（右边），表示最近经常使用；当 accessOrder = false 时，key 的顺序为插入双向链表时的顺序

![image-20210207194714608](https://img-blog.csdnimg.cn/img_convert/b2d5a55df4837226e085710d78a0d8f6.png)

https://blog.csdn.net/oneby1314/article/details/113789412

### 手动实现LRU



[146. LRU 缓存](https://leetcode.cn/problems/lru-cache/)

```java
class LRUCache {
    int capacity;
    int size;
    Node head;
    Map<Integer, Node> map = new HashMap<>();

    static class Node {
        int key;
        int val;
        Node next;
        Node prev;

        Node () {}
        Node(int key, int val) {
            this.key = key;
            this.val = val;
        }

        Node remove() {
            prev.next = next;
            next.prev = prev;
            next = null;
            prev = null;
            return this;
        }

        void insert(Node node) {
            node.next = next;
            node.prev = this;
            next.prev = node;
            next = node;
        }
    }

    public LRUCache(int capacity) {
        this.capacity = capacity;
        head = new Node();
        head.next = head;
        head.prev = head;
    }
    
    public int get(int key) {
        Node node = map.get(key);
        if (node == null) return -1;

        node = node.remove();
        head.insert(node);
        return node.val;
    }
    
    public void put(int key, int value) {
        Node node = map.get(key);
        if (node == null) {
            node = new Node(key, value);
            map.put(key, node);
            size++;
        } else {
            node = node.remove();
            node.val = value;
        }

        head.insert(node);
        if (size > capacity) {
            Node removed = head.prev.remove();
            map.remove(removed.key);
            size--;
        }
    }
}
```



## 手写红黑树

会涉及到2-3树

https://zhuanlan.zhihu.com/p/362478152





## ACM模式-Java

### 输入输出

#### 字符串输入输出

输入描述:

```
多个测试用例，每个测试用例一行。
每行通过,隔开，有n个字符，n＜100
```

输出描述:

```
对于每组用例输出一行排序后的字符串，用','隔开，无结尾空格
```

输入

```
a,c,bb
f,dddd
nowcoder
```

输出

```
a,bb,c
dddd,f
nowcoder
```



```java
import java.util.*;
public class Main{
    
    public static void main(String[] args){
        Scanner sc = new Scanner(System.in);
        while(sc.hasNextLine()){
            String str = sc.nextLine();
            String []arr = str.split(",");
            Arrays.sort(arr);
            int k ;
            for( k=0;k<arr.length-1;k++){
                System.out.print(arr[k]+",");
            }
            System.out.println(arr[k]);
        }
    }
}
```



#### 数字输入输出

输入描述:

```
输入数据有多组, 每行表示一组输入数据。

每行不定有n个整数，空格隔开。(1 <= n <= 100)。
```

输出描述:

```
每组数据输出求和的结果                      
```

输入

```
1 2 3
4 5
0 0 0 0 0
```

输出

```
6
9
0
```



```java

import java.util.*;

public class Main {
    public static void main(String[] args) throws IOException {
        Scanner sc = new Scanner(System.in);
        while(sc.hasNextLine()){
            String str = sc.nextLine();
            String []arr = str.split(" ");
            int sum =  0;
            for(String s : arr){
                sum += Integer.parseInt(s);
            }
            System.out.println(sum);
        }
    }
 
```



### API

#### 比较器

二维数组比较

```
        Arrays.sort(nums,new Comparator<int[]>(){
            public int compare(int[] inter1, int[] inter2){
                return inter1[0] - inter2[0];
            }
        });
```

lambda表达式-数组

```
Arrays.sort(arr, (o1, o2) -> o1-o2);
```

lambda表达式-集合

```
list.sort((a,b)->a-b);
list.sort((a,b)->a.compareTo(b));
```

#### 保留n位小数å

```
BigDecimal a = new BigDecimal("1.10218");
a = a.setScale(4,BigDecimal.ROUND_HALF _UP);//四舍五入保留四位小数
System.out.println(a);
```

#### java两位小数

```java
int a=3;
int b=2;
double c;
DecimalFormat df=new DecimalFormat("0.00");
System.out.println(df.format((float)a/b));
```

#### 自定义优先队列

```java
PriorityQueue<Integer> heap = new 
						PriorityQueue<>((o1, o2) -> o2.compareTo(o1));

 PriorityQueue<Integer> heap = new 
   PriorityQueue<>(new Comparator<Integer>() {
            @Override
            public int compare(Integer o1, Integer o2) {
                return o2.compareTo(o1);
            }
        });
```



### 字典树模版

```java

class Trie {

    class TireNode {
        private boolean isEnd;
        TireNode[] next;

        public TireNode() {
            isEnd = false;
            next = new TireNode[26];
        }
    }

    private TireNode root;

    public Trie() {
        root = new TireNode();
    }

    public void insert(String word) {
        TireNode node = root;
        for (char c : word.toCharArray()) {
            if (node.next[c - 'a'] == null) {
                node.next[c - 'a'] = new TireNode();
            }
            node = node.next[c - 'a'];
        }
        node.isEnd = true;
    }

    public boolean search(String word) {
        TireNode node = root;
        for (char c : word.toCharArray()) {
            node = node.next[c - 'a'];
            if (node == null) {
                return false;
            }
        }
        return node.isEnd;
    }

    public boolean startsWith(String prefix) {
        TireNode node = root;
        for (char c : prefix.toCharArray()) {
            node = node.next[c - 'a'];
            if (node == null) {
                return false;
            }
        }
        return true;
    }
}
```

https://blog.csdn.net/m0_46202073/article/details/107253959

https://leetcode.cn/problems/implement-trie-prefix-tree/

### 并查集模版

https://leetcode.cn/problems/number-of-provinces/