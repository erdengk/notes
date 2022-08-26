### 讲讲深浅拷贝

1、浅拷贝：对基本数据类型进行值传递，对引用数据类型进行引用传递般的拷贝，此为浅拷贝

2、深拷贝：对基本数据类型进行值传递，对引用数据类型，创建一个新的对象，并复制其内容，此为深拷贝。

https://segmentfault.com/a/1190000010648514



为什么要准备两个空数组？



讲讲transient关键字？



Arrays.asList() 的使用场景是？

```
// asList 用在固定的多个值的情况，不进行修改的情况下使用。
// 不能删除或者增加，可以修改值
// 确保任何情况下都不能对这个list进行size的修改
```



Collections.emptyList() 使用场景？

```
// 代码中的一个if或者else 需要返回空list时，使用这个
// 如果直接使用 new ArrayList 的话，会有对象的创建
// Collections.emptyList() 无需进行创建
// Arrays.asList() 也会创建对象，浪费一定的空间  不建议使用（不是不能用）
```





removeRange(int fromIndex, int toIndex)  开头和结尾的元素是否被删除？

```java

public class SubArrayList extends ArrayList {
 
	public static void main(String[] args) {
		SubArrayList arrayList = new SubArrayList();
		Integer integer = 0;
		Integer integer1 = 1;
		Integer integer2 = 2;
		Integer integer3 = 3;
		Object object = null;
 
		arrayList.add(integer);
		arrayList.add(integer1);
		arrayList.add(integer2);
		arrayList.add(integer3);
		arrayList.add(object);
 
		// 移除下标为1,2的元素
		arrayList.removeRange(1, 3);
 
		// 常规for循环遍历
		System.out.println("常规for循环遍历：");
		for (int i = 0; i < arrayList.size(); i++) {
			System.out.println("object:" + arrayList.get(i));
		}
	}

常规for循环遍历：
object:0
object:3
object:null
```

开头不被删，结尾的会被删

这种类似数组下标区间一般都是取下不取上，即[min, max) ，包含min而不包含max。[1]





### 序列化是什么？为什么要序列化？

序列化是指把一个Java对象变成二进制内容，本质上就是一个`byte[]`数组。

为什么要把Java对象序列化呢？

因为序列化后可以把`byte[]`保存到文件中，或者把`byte[]`通过网络传输到远程，这样，就相当于把Java对象存储到文件或者通过网络传输出去了。

为什么要序列化，那就是说一下序列化的好处喽，序列化有什么什么优点，所以我们要序列化。

优点：

**一：对象序列化可以实现分布式对象。**

主要应用例如：RMI(即远程调用Remote Method Invocation)要利用对象序列化运行远程主机上的服务，就像在本地机上运行对象时一样。

**二：java对象序列化不仅保留一个对象的数据，而且递归保存对象引用的每个对象的数据。**

可以将整个对象层次写入字节流中，可以保存在文件中或在网络连接上传递。利用对象序列化可以进行对象的"深复制"，即复制对象本身及引用的对象本身。序列化一个对象可能得到整个对象序列。

**三：序列化可以将内存中的类写入文件或数据库中。**

比如：将某个类序列化后存为文件，下次读取时只需将文件中的数据反序列化就可以将原先的类还原到内存中。也可以将类序列化为流数据进行传输。

总的来说就是将一个已经实例化的类转成文件存储，下次需要实例化的时候只要反序列化即可将类实例化到内存中并保留序列化时类中的所有变量和状态。

**四：对象、文件、数据，有许多不同的格式，很难统一传输和保存。**

序列化以后就都是字节流了，无论原来是什么东西，都能变成一样的东西，就可以进行通用的格式传输或保存，传输结束以后，要再次使用，就进行反序列化还原，这样对象还是对象，文件还是文件。【2】

[1] : https://blog.csdn.net/weixin_41287260/article/details/95357183

[2] : https://www.cnblogs.com/javazhiyin/p/11841374.html