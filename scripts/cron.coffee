# Description:
#   slack bot for me
cron = require('cron').CronJob
{EventEmitter} = require 'events'
emitter = new EventEmitter
moment = require("moment")
moment.locale('ja', {
  weekdaysShort: ["日","月","火","水","木","金","土"]
})
config = require("./config")
room = config.room
weather = config.url.weather

module.exports = (robot) ->
  emitter.on 'send', (robot, message) ->
    robot.send {room: room}, message

  # morning message
  new cron '0 0 8 * * *', () ->
    Task.morning(robot)
    Task.weather(robot)
    Task.hatena(robot)
  , null, true, "Asia/Tokyo"

  # night messege
  new cron '0 0 23 * * *', () ->
    Task.garbage(robot)
  , null, true, "Asia/Tokyo"

Task = {
  morning: (robot) ->
    today = moment().format("MM/DD(ddd)")
    emitter.emit 'send', robot, ":sunny::sunny::sunny::sunny::sunny:\n:sunglasses: < おはようございます！\n今日は#{today}です。\n\n"
  hatena: (robot) ->
    emitter.emit 'send', robot, "【はてブ】\nテクノロジー\nhttp://b.hatena.ne.jp/ctop/it\nマイホットエントリー\nhttp://b.hatena.ne.jp/do7be/hotentry\n関心ワード\nhttp://b.hatena.ne.jp/do7be/interest\n\n"
  weather: (robot) ->
    data = JSON.stringify({
      text: '天気 今日 東京'
    })
    robot.http(weather)
      .header('Content-Type', 'application/json')
      .post(data) (err, res, body) ->
        if err
          emitter.emit 'send', robot, "sorry. weather disable.\n"
        resData = JSON.parse body
        icon = resData.icon_url.replace(/\\/g, "")
        emitter.emit 'send', robot, "【天気】\n#{resData.text}\n#{icon}\n\n#{resData.description}\n\n"
  garbage: (robot) ->
    weekday = moment().utcOffset("+24:00").format("dddd")
    if config.garbage[weekday]?
      weekdayJa = moment().utcOffset("+24:00").format("ddd")
      emitter.emit 'send', robot, ":crescent_moon::crescent_moon::crescent_moon::crescent_moon::crescent_moon:\n:sleeping: < 明日は#{weekdayJa}曜日なので#{config.garbage[weekday]}の日です。\n捨て忘れないようにしましょう。\n\n"
}
