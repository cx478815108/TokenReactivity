
# TokenReactivity

来自前端框架Vue3 的灵感，Vue3 的数据依赖收集是实现响应式的基石。
如果你有兴趣可以看一下Vue3的 [Vue Composition API](https://composition-api.vuejs.org/#basic-example)

**TokenReactivity** 实现了Vue3 的effect API，让OC 的响应式也可以非常简单

## Vue3 Composition API

看看Vue3 的UnitTest

```
let dummy
const obj = reactive({ prop: 1 })
effect(function(){
  dummy = obj.prop
})
obj.prop = 2
expect(dummy).toBe(1)
```
很明显 API 设计的非常简洁，当`obj.prop`的值改变后 立即执行`dummy = obj.prop`

## Objective-C

在OC里面 不借助其他框架想要监听该如何实现呢，你可能想到的想法非常多，比如封装KVO？
让我们看看KVO 又臭又长的使用，它让本应该写在一起的逻辑，分散开来

```
1. 添加观察的keyPath
[xxx addObserver:xxx forKeyPath:@"xxx" options:options context:xxx];

2. 实现这个方法，当值改变的时候
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 
}

3. 移除监听
-(void)dealloc
{
    // 移除监听
    [xxx removeObserver:xxx forKeyPath:xxx];
}

```

熟悉OC 的开发者应该知道KVO 内部做了什么事情，并且使用起来也并没有那么方便，如果处理不当，非常容易crash 

## Use TokenReactivity

看看TokenReactivity 能够做一些什么把

```
// 让People 支持响应式
TokenObserve([People class]);

People *student = [[People alloc] init];
__block int age = 0;

// 类似Vue 的effetc 函数
TokenEffect(^{
    age = student.age;
});

student.age = 20

NSLog(@"age:%@", @(age)); // 输出 age:20
```
简单吧？

这是直接改动了student的age ，假如这样写呢？

```
TokenEffect(^{
    age = student.girlfriend.age;
});
```

也是支持的

现在你可以尝试用 `TokenReactivity` 做一些有意思的事情了







