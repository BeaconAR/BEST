import requests
import json

# Send Notifications to Mobile device.
# Need to make Database of ID
def send_notification():
    datas = {
        "to": "dUvNnqwKwU8yjpFH8OzTJX:APA91bF8xVOIcIAsqWkb9f-DS-Q2YlkSCdxfDYA0dMQuOI318S1fv0H-ZJeCTEfLFaL8DT6ouyqLncn76hpmmzUTHhZnQRdyOECHlpey6A-b698RVCZBpr-1PIRfHay0NAVJ8Ry7K9p9",
        "data": {
            "title": "Fire Fire Fire!",
            "message": "Open to start evacuate"
        },
        "notification": {
            "title": "fire",
            "body": "test2",
            "sound": "default"
        }
    }
    url = "https://fcm.googleapis.com/fcm/send"
    headers = {'Content-Type':'application/json', 'Authorization':'key=AAAAmGbQ4Uo:APA91bFnyyCa1iUa_wvE0XGHfGcvMOKUEf4nfWHZAANqtIqcS-4PkDP7Sc6gJTkDIbinsXCLs3IQfMai2LsnzpQEoQ618fyZpww5gPdMY4qmGu95vu9i5ttCh6VuNZw_A--xhifJqQGQ'}

    print(datas)
    print(headers)
    datas = json.dumps(datas)
    response = requests.post(url, data=datas, headers=headers)
