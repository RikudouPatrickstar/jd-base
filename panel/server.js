
/*
 * @Author: Jerrykuku https://github.com/jerrykuku
 * @Date: 2021-1-6
 * @Version: v0.0.1
 */

var express = require('express');
var session = require('express-session');
var bodyParser = require('body-parser');
var path = require('path');
var fs = require('fs');
const e = require('express');

var rootPath = path.resolve(__dirname, '..')
// config.sh 文件所在目录
var confFile = path.join(rootPath,'config/config.sh');
// config.sh.sample 文件所在目录
var sampleFile = path.join(rootPath,'sample/config.sh.sample');
var crontabFile = path.join(rootPath,'config/crontab.list');
// config.sh 文件备份目录
var confBakDir = path.join(rootPath,'config/bak/');;
var authConfigFile = path.join(rootPath,'config/auth.json');

var authError = "错误的用户名密码，请重试";
var loginFaild = "请先登录!";

var configString = "config sample crontab";


/**
 * 检查 config.sh 以及 config.sh.sample 文件是否存在
 */
function checkConfigFile() {
    if (!fs.existsSync(confFile)) {
        console.error('脚本启动失败，config.sh 文件不存在！');
        process.exit(1);
    }
    if (!fs.existsSync(sampleFile)) {
        console.error('脚本启动失败，config.sh.sample 文件不存在！');
        process.exit(1);
    }
}

/**
 * 检查 config/bak/ 备份目录是否存在，不存在则创建
 */
function mkdirConfigBakDir() {
    if (!fs.existsSync(confBakDir)) {
        fs.mkdirSync(confBakDir);
    }
}

/**
 * 备份 config.sh 文件
 */
function bakConfFile(file) {
    mkdirConfigBakDir();
    let date = new Date();
    let bakConfFile = confBakDir + file + '_' + date.getFullYear() + '-' + date.getMonth() + '-' + date.getDay() + '-' + date.getHours() + '-' + date.getMinutes() + '-' + date.getMilliseconds();

    let oldConfContent = getFileContentByName(confFile);
    fs.writeFileSync(bakConfFile, oldConfContent);
}

/**
 * 将 post 提交内容写入 config.sh 文件（同时备份旧的 config.sh 文件到 bak 目录）
 * @param content
 */
function saveNewConf(file, content) {
    bakConfFile(file);
    switch (file) {
        case "config.sh":
            fs.writeFileSync(confFile, content);
            break;
        case "crontab.list":
            fs.writeFileSync(crontabFile, content);
            break;
        default:
            break;
    }
}

/**
 * 获取文件内容
 * @param fileName 文件路径
 * @returns {string}
 */
function getFileContentByName(fileName) {
    if (fs.existsSync(fileName)) {
        return fs.readFileSync(fileName, 'utf8');
    }
    return '';
}


var app = express();
app.use(session({
    secret: 'secret',
    resave: true,
    saveUninitialized: true
}));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

/**
 * 登录页面
 */
app.get('/', function (request, response) {
    if (request.session.loggedin) {
        response.redirect('/home');
    } else {
        response.sendFile(path.join(__dirname + '/public/auth.html'));
    }
});

/**
 * 用户名密码
 */
app.get('/changepwd', function (request, response) {
    if (request.session.loggedin) {
        response.sendFile(path.join(__dirname + '/public/pwd.html'));
    } else {
        response.redirect('/');
    }
});


/**
 * 获取各种配置文件api
 */

app.get('/api/config/:key', function (request, response) {
    if (request.session.loggedin) {
        if (configString.indexOf(request.params.key) > -1) {
            switch (request.params.key) {
                case 'config':
                    content = getFileContentByName(confFile);
                    break;
                case 'sample':
                    content = getFileContentByName(sampleFile);
                    break;
                case 'crontab':
                    content = getFileContentByName(crontabFile);
                    break;
                default:
                    break;
            }
            response.setHeader("Content-Type", "text/plain");
            response.send(content);
        } else {
            response.send("no config");
        }
    } else {
        response.send(loginFaild);
    }
    response.end();
})

/**
 * 首页 配置页面
 */
app.get('/home', function (request, response) {
    if (request.session.loggedin) {
        response.sendFile(path.join(__dirname + '/public/home.html'));
    } else {
        response.redirect('/');
    }

});

/**
 * 对比 配置页面
 */
app.get('/diff', function (request, response) {
    if (request.session.loggedin) {
        response.sendFile(path.join(__dirname + '/public/diff.html'));
    } else {
        response.redirect('/');
    }

});

/**
 * crontab 配置页面
 */
app.get('/crontab', function (request, response) {
    if (request.session.loggedin) {
        response.sendFile(path.join(__dirname + '/public/crontab.html'));
    } else {
        response.redirect('/');
    }

});


/**
 * auth
 */
app.post('/auth', function (request, response) {
    let username = request.body.username;
    let password = request.body.password;
    fs.readFile(authConfigFile, 'utf8', function (err, data) {
        if (err) console.log(err);
        var con = JSON.parse(data);
        if (username && password) {
            if (username == con.user && password == con.password) {
                request.session.loggedin = true;
                request.session.username = username;
                response.redirect('/home');
            } else {
                response.send('Incorrect Username and/or Password!');
                response.end();
            }
        } else {
            response.send('Please enter Username and Password!');
            response.end();
        }
    });

});

/**
 * change pwd
 */
app.post('/changepass', function (request, response) {
    if (request.session.loggedin) {
        let username = request.body.username;
        let password = request.body.password;
        let config = {
            user: username,
            password: password
        }
        fs.writeFile(authConfigFile, JSON.stringify(config), function (err) {
            if (err) {
                response.send('写入错误请重试!');
                response.end();
            } else {
                response.send('更新成功!');
                response.end();
            }
        })

    } else {
        response.send(loginFaild);
        response.end();
    }
});

/**
 * change pwd
 */
app.get('/logout', function (request, response) {
    request.session.destroy()
    response.redirect('/');
    response.end();
});

/**
 * save config
 */

app.post('/api/save', function (request, response) {
    if (request.session.loggedin) {
        let postContent = request.body.content;
        let postfile = request.body.name;
        saveNewConf(postfile, postContent);
        content = 'config.sh 保存成功! 将自动刷新页面查看修改后的 config.sh 文件';
        response.send(content);
    } else {
        response.send(loginFaild);
    }
    response.end();
});

checkConfigFile()

app.listen(5678, () => {
    console.log('应用正在监听 5678 端口!');
});