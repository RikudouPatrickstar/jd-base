/*
 * @Author: FanchangWang https://github.com/FanchangWang
 * @Date: 2020-12-29 22:56:31
 * @Version: v3.0.0
 */

const http = require('http');
const url = require('url');
const fs = require('fs');

// config.sh 文件所在目录
var confDir = './config/';
var confFile = confDir + 'config.sh';
// config.sh.sample 文件所在目录
var sampleDir = './sample/';
var sampleFile = sampleDir + 'config.sh.sample';
// config.sh 文件备份目录
var confBakDir = confDir + 'bak/';
// diff.html 网页源码
var diffHtmlFile = './diff/diff.html';

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
function bakConfFile() {
    mkdirConfigBakDir();
    let date = new Date();
    let bakConfFile = confBakDir + 'config.sh_' + date.getFullYear() + '-' + date.getMonth() + '-' + date.getDay() + '-' + date.getHours() + '-' + date.getMinutes() + '-' + date.getMilliseconds();

    let oldConfContent = getConfFileContent();
    fs.writeFileSync(bakConfFile, oldConfContent);
}

/**
 * 将 post 提交内容写入 config.sh 文件（同时备份旧的 config.sh 文件到 bak 目录）
 * @param content
 */
function saveNewConf(content) {
    bakConfFile();
    fs.writeFileSync(confFile, content);
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

/**
 * 获取 diff.html 内容
 * @returns {string}
 */
function getDiffHtmlContent() {
    return getFileContentByName(diffHtmlFile);
}

/**
 * 获取 config.sh 文件内容
 * @returns {string}
 */
function getConfFileContent() {
    return getFileContentByName(confFile);
}

/**
 * 获取 config.sh.sample 文件内容
 * @returns {string}
 */
function getSampleFileContent() {
    return getFileContentByName(sampleFile);
}

/**
 * 创建 http 服务器
 */
function createHttpServer() {
    var server = new http.Server();
    try {
        server.on('request', function (request, response) {
            try {
                let content = '';
                let uri = url.parse(request.url);
                switch (request.method) {
                    case 'GET':
                        switch (uri.pathname) {
                            case '/diff':
                                response.writeHead(200, {'Content-Type': 'content-type: text/html; charset=utf-8'});
                                content = getDiffHtmlContent();
                                break;
                            case '/config':
                                response.writeHead(200, {'Content-Type': 'text/plain'});
                                content = getConfFileContent();
                                break;
                            case '/sample':
                                response.writeHead(200, {'Content-Type': 'text/plain'});
                                content = getSampleFileContent();
                                break;
                            default:
                                if (uri.pathname.indexOf('/diff/') === 0) {
                                    let fileName = '.' + uri.pathname;
                                    if (fs.existsSync(fileName)) {
                                        if (uri.pathname.indexOf('/diff/js/') === 0) {
                                            response.writeHead(200, {'Content-Type': 'application/javascript'});
                                            content = getFileContentByName(fileName);
                                        } else if (uri.pathname.indexOf('/diff/css/') === 0) {
                                            response.writeHead(200, {'Content-Type': 'text/css'});
                                            content = getFileContentByName(fileName);
                                        }
                                    } else {
                                        response.writeHead(404, {'Content-Type': 'text/plain'});
                                        content = '404 NOT FOUND';
                                    }
                                } else {
                                    response.writeHead(404, {'Content-Type': 'text/plain'});
                                    content = '404 NOT FOUND';
                                }
                        }
                        response.end(content);
                        break;
                    case 'POST':
                        switch (uri.pathname) {
                            case '/save':
                                let post = '';
                                request.setEncoding("utf8");
                                request.on('data', function (chunk) {
                                    post += chunk;
                                });
                                request.on('end', function () {
                                    saveNewConf(post);
                                    response.writeHead(200, {'Content-Type': 'text/plain'});
                                    content = 'config.sh 保存成功! 将自动刷新页面查看修改后的 config.sh 文件';
                                    response.end(content);
                                });
                                break;
                            default:
                                response.writeHead(404, {'Content-Type': 'text/plain'});
                                content = '404 NOT FOUND';
                                response.end(content);
                        }
                        break;
                    default:
                        response.writeHead(404, {'Content-Type': 'text/plain'});
                        content = '404 NOT FOUND';
                        response.end(content);
                }
            } catch (e) {
                console.error('http server request error，errmsg:', e);
                response.writeHead(500, {'Content-Type': 'text/plain'});
                response.end('server error!');
            }
        });
        server.listen(5678);
    } catch (e) {
        console.log('脚本启动失败，errmsg:', e);
        process.exit(1);
    }
}

checkConfigFile();
createHttpServer();

console.log("############################################################");
console.log("##");
console.log("## config.sh 文件对比脚本启动成功");
console.log("## 请使用浏览器访问 http://127.0.0.1:5678/diff 进行对比修改");
console.log("## 如果您访问的非本机网络，请将 127.0.0.1 替换成脚本所在机器的 ip 地址");
console.log("## 结束脚本请按 `ctrl + c`");
console.log("##");
console.log("############################################################\n");
