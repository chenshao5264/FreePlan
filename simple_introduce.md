####结构说明
> apis: 引擎的api和自定义扩展api(ccEx)
> lobby: 大厅源码(srcc)和资源(res)
> hzmj: 小游戏源码(srcc)和资源(res)

这样分级的好处，热更新时下载对应的包

####小游戏用到的lobby的apis
1. 进入小游戏
```
myApp:launchGame(name)
```
小游戏编写者不需要主动调用改api，只要负责对应小游戏main文件中launch()的实现,
如数据初始化，切换场景到小游戏的GameScene.

2. 退出小游戏
```
myApp:exitGame()
```
退出小游戏时，主动调该api，同时负责对应小游戏main文件中exit()的实现,
如数据的清空，但不需要做切换场景处理

3. gg.Player
```
Player:getUserID()          --// 获取用户userid
Player:getNickname()        --// 获取用户昵称
Player:getSelectedTableID() --// 获取玩家桌子号
Player:getSelectedChairID() --// 获取玩家椅子号
```

4. 公共工具类
该工具类lobby和小游戏会同时使用到。
公共的工具类放在lobby/public下，由lobby编写人员负责。
