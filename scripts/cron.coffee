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
    today = moment().tz("Asia/Tokyo").format("MM/DD(ddd)")
    emitter.emit 'send', robot, ":sunny::sunny::sunny::sunny::sunny:\n:sunglasses: < おはようございます！\n今日は#{today}です。\n\n"
  hatena: (robot) ->
    emitter.emit 'send', robot, "【はてブ】\nテクノロジー\nhttp://b.hatena.ne.jp/ctop/it\nマイホットエントリー\nhttp://b.hatena.ne.jp/do7be/hotentry\n関心ワード\nhttp://b.hatena.ne.jp/do7be/interest\n\n"
  weather: (robot) ->
    query = {city: '東京'};
    robot.http(weather)
      .query(query)
      .get() (err, res, body) ->
        if err
          emitter.emit 'send', robot, "sorry. weather disable.\n"
        resData = JSON.parse body

        icon = resData.forecasts[0].image.url
        location = resData.location.city
        temp_max = '?'
        temp_min = '?'
        if resData.forecasts[0].temperature.max?
          temp_max = resData.forecasts[0].temperature.max.celcius
        if resData.forecasts[0].temperature.min?
          temp_min = resData.forecasts[0].temperature.min.celcius
        telop = resData.forecasts[0].telop
        today = moment().tz("Asia/Tokyo").format("MM/DD(ddd)")
        text = "#{today} #{location}の天気\n#{telop} #{temp_max}℃/#{temp_min}℃"
        emitter.emit 'send', robot, "【天気】\n#{text}\n#{icon}\n\n#{resData.description.text}\n\n"
  garbage: (robot) ->
    weekday = moment().tz("Asia/Tokyo").utcOffset("+24:00").format("dddd")
    if config.garbage[weekday]?
      weekdayJa = moment().tz("Asia/Tokyo").utcOffset("+24:00").format("ddd")
      emitter.emit 'send', robot, ":crescent_moon::crescent_moon::crescent_moon::crescent_moon::crescent_moon:\n:sleeping: < 明日は#{weekdayJa}曜日なので#{config.garbage[weekday]}の日です。\n捨て忘れないようにしましょう。\n\n"
}
