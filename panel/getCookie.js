/*
 * 使用 京东 APP 扫码获取 Cookie 脚本（自动获取 pt_key=xxx;pt_pin=xxx;)
 * 
 * @Author: FanchangWang https://github.com/FanchangWang 
 * @Date: 2021-01-07 18:00:21 
 * @Desc: 只是实现了功能，语法跟使用的模块都不是很好，希望有对 nodejs 熟悉的帮忙重新整理下
 */

const requestPromise = require('request-promise');
const qrcode = require('qrcode-terminal');

console.log("正在获取二维码，请打开京东 APP 准备扫码登录\n");

var s_token, cookies, guid, lsid, lstoken, okl_token, token
var timeStamp = (new Date()).getTime()
var mGet = {
  uri: 'https://plogin.m.jd.com/cgi-bin/mm/new_login_entrance?lang=chs&appid=300&returnurl=https://wq.jd.com/passport/LoginRedirect?state=' + timeStamp + '&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport',
  headers: {
    'Connection': 'Keep-Alive',
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'zh-cn',
    'Referer': 'https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wq.jd.com/passport/LoginRedirect?state=' + timeStamp + '&returnurl=https://home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
    'Host': 'plogin.m.jd.com'
  },
  json: true,
  resolveWithFullResponse: true
};
requestPromise(mGet)
  .then(function (response) {
    // console.log(response);
    s_token = response.body.s_token
    guid = response.headers['set-cookie'][0]
    guid = guid.substring(guid.indexOf("=") + 1, guid.indexOf(";"))
    lsid = response.headers['set-cookie'][2]
    lsid = lsid.substring(lsid.indexOf("=") + 1, lsid.indexOf(";"))
    lstoken = response.headers['set-cookie'][3]
    lstoken = lstoken.substring(lstoken.indexOf("=") + 1, lstoken.indexOf(";"))
    cookies = "guid=" + guid + "; lang=chs; lsid=" + lsid + "; lstoken=" + lstoken + "; "
    // console.log("s_token:" + s_token);
    // console.log("cookies:" + cookies);
    timeStamp = (new Date()).getTime()
    var mPost = {
      method: 'POST',
      uri: 'https://plogin.m.jd.com/cgi-bin/m/tmauthreflogurl?s_token=' + s_token + '&v=' + timeStamp + '&remember=true',
      form: {
        'lang': 'chs',
        'appid': 300,
        'returnurl': 'https://wqlogin2.jd.com/passport/LoginRedirect?state=' + timeStamp + '&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action',
        'source': 'wq_passport'
      },
      headers: {
        'Connection': 'Keep-Alive',
        'Content-Type': 'application/x-www-form-urlencoded; Charset=UTF-8',
        'Accept': 'application/json, text/plain, */*',
        'Cookie': cookies,
        'Referer': 'https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=' + timeStamp + '&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
        'Host': 'plogin.m.jd.com',
      },
      json: true, // Automatically stringifies the body to JSON
      resolveWithFullResponse: true
    };
    requestPromise(mPost)
      .then(function (response) {
        // console.log(response)
        token = response.body.token
        okl_token = response.headers['set-cookie'][0]
        okl_token = okl_token.substring(okl_token.indexOf("=") + 1, okl_token.indexOf(";"))
        // console.log("token:" + token);
        // console.log("okl_token:" + okl_token);

        var mInterval = setInterval(function(){
          timeStamp = (new Date()).getTime()
          var mPostCheck = {
            method: 'POST',
            uri: 'https://plogin.m.jd.com/cgi-bin/m/tmauthchecktoken?&token=' + token + '&ou_state=0&okl_token=' + okl_token,
            form: {
              lang: 'chs',
              appid: 300,
              returnurl: 'https://wqlogin2.jd.com/passport/LoginRedirect?state=1100399130787&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action',
              source: 'wq_passport'
            },
            headers: {
              'Referer': 'https://plogin.m.jd.com/login/login?appid=300&returnurl=https://wqlogin2.jd.com/passport/LoginRedirect?state=' + timeStamp + '&returnurl=//home.m.jd.com/myJd/newhome.action?sceneval=2&ufc=&/myJd/home.action&source=wq_passport',
              'Cookie': cookies,
              'Connection': 'Keep-Alive',
              'Content-Type': 'application/x-www-form-urlencoded; Charset=UTF-8',
              'Accept': 'application/json, text/plain, */*',
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36',
            },
            json: true, // Automatically stringifies the body to JSON
            resolveWithFullResponse: true
          };
          // console.log(mPostCheck.uri)
          requestPromise(mPostCheck)
            .then(function (response) {
              // console.log(response)
              if(response.body.errcode == 0){ // 获取到
                clearInterval(mInterval);
                var TrackerID = response.headers['set-cookie'][0]
                TrackerID = TrackerID.substring(TrackerID.indexOf("=") + 1, TrackerID.indexOf(";"))
                var pt_key = response.headers['set-cookie'][1]
                pt_key = pt_key.substring(pt_key.indexOf("=") + 1, pt_key.indexOf(";"))
                var pt_pin = response.headers['set-cookie'][2]
                pt_pin = pt_pin.substring(pt_pin.indexOf("=") + 1, pt_pin.indexOf(";"))
                var pt_token = response.headers['set-cookie'][3]
                pt_token = pt_token.substring(pt_token.indexOf("=") + 1, pt_token.indexOf(";"))
                var pwdt_id = response.headers['set-cookie'][4]
                pwdt_id = pwdt_id.substring(pwdt_id.indexOf("=") + 1, pwdt_id.indexOf(";"))
                var s_key = response.headers['set-cookie'][5]
                s_key = s_key.substring(s_key.indexOf("=") + 1, s_key.indexOf(";"))
                var s_pin = response.headers['set-cookie'][6]
                s_pin = s_pin.substring(s_pin.indexOf("=") + 1, s_pin.indexOf(";"))
                // console.log("TrackerID:" + TrackerID);
                // console.log("pt_key:" + pt_key);
                // console.log("pt_pin:" + pt_pin);
                // console.log("pt_token:" + pt_token);
                // console.log("pwdt_id:" + pwdt_id);
                // console.log("s_key:" + s_key);
                // console.log("s_pin:" + s_pin);
                cookies = "TrackerID=" + TrackerID + "; pt_key=" + pt_key + "; pt_pin=" + pt_pin + "; pt_token=" + pt_token + "; pwdt_id=" + pwdt_id + "; s_key=" + s_key + "; s_pin=" + s_pin + "; wq_skey="
                // console.log("cookies:" + cookies);
                var cookie1 = "pt_key=" + pt_key + ";pt_pin=" + pt_pin + ";";

                console.log("\n############  登录成功，获取到 Cookie  #############\n\n");
                console.log('Cookie1="' + cookie1 + '"\n');
                console.log("\n####################################################\n\n");

                var mGet = {
                  uri: 'https://wq.jd.com/user/info/QueryJDUserInfo?sceneval=2&g_login_type=1&callback=',
                  headers: {
                    'Connection': 'Keep-Alive',
                    'Accept': '*/*',
                    'Cookie': cookies,
                    'Referer': 'https://wq.jd.com/user/info/QueryJDUserInfo?sceneval=2&g_login_type=1&callback=',
                    'User-Agent': 'jdapp;iPhone;9.2.0;13.5;;network/wifi;ADID/;JDEbook/openapp.jdreader;supportApplePay/3;hasUPPay/1;pushNoticeIsOpen/1;model/iPhone10,3;addressid/;hasOCPay/0;appBuild/167408;supportBestPay/0;jdSupportDarkMode/0;pv/1070.27;apprpd/Home_Main;ref/JDMainPageViewController;psq/11;ads/;psn/|2612;jdv/0|kong||jingfen||;adk/;app_device/IOS;pap/JA2015_311210|9.2.0|IOS 13.5;Mozilla/5.0 (iPhone; CPU iPhone OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148;supportJDSHWK/1',
                    'Host': 'wq.jd.com'
                  },
                  json: true,
                  resolveWithFullResponse: true
                };
                requestPromise(mGet)
                  .then(function (response) {
                    console.log("当前登录用户昵称：" + response.body.base.nickname);
                  })
              }
            })
        },3000);

        var url = 'https://plogin.m.jd.com/cgi-bin/m/tmauth?appid=300&client_type=m&token=' + token;
        qrcode.generate(url,{small:true}); // 输出二维码
        console.log("请扫码登录，正在检测是否扫码成功（每 3 秒检测一次）……");
      })
  })