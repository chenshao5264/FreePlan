var fs = require("fs")
var crypto = require('crypto');

function geFileList(path, filesList, walkDir)
{	
	readFile(path, filesList, walkDir);
	return filesList;
}

var _walkDir = process.env.WALKDIR || "../";
var _outDir = process.env.OUT_DIR || "./"
var _excludeDir = process.env.EXCLUDE_DIR || ""
var url = process.env.URL || "";
var version = process.env.VERSION || "1.0.0";
var _target = process.env.TARGET || "ios"
var _pagkageName = process.env.PACKAGENAME || "lobby"

var differenceFiles = [];

//遍历读取文件
function readFile(path, filesList, walkDir) {
	var files = fs.readdirSync(path);//需要用到同步读取
	files.forEach(walk);
	function walk(file){
		
		if (file == ".DS_Store") {
			return;
		}
		
		var states = fs.statSync(path + '/' + file);   
		if(states.isDirectory()) {
			if (path != _excludeDir) {
				readFile(path + '/' + file, filesList, walkDir);
			}
		}
		else { 
			//创建一个对象保存信息
			var obj = new Object();
			var fullPath = path + '/' + file;
			
			obj.path = fullPath.substring(walkDir.length, fullPath.length);
			obj.name = obj.path;
			obj.size = states.size;//文件大小，以字节为单位
			var text = fs.readFileSync(fullPath);
			obj.md5 = crypto.createHash('md5').update(text, 'utf-8').digest('hex');
			
			filesList.push(obj);
  		}  
 	}
}

function isTheSameFile(file1, file2) {
	var text1 = fs.readFileSync(file1);
	var text2 = fs.readFileSync(file2);
	
	var md51 = crypto.createHash('md5').update(text1, 'utf-8').digest('hex');
	var md52 = crypto.createHash('md5').update(text2, 'utf-8').digest('hex');
	
	if (md51 === md52) {
		return true;
	} else {
		return false;
	}
}


var filesList = []
filesList = geFileList(_walkDir, filesList, _walkDir);


	
function write2manifest() {
	var obj = {
		"assets" : {},
		"packageUrl" : url,
		"remoteManifestUrl": url + "manifests/" + "project_" + _pagkageName + ".manifest",
		"remoteVersionUrl": url + "manifests/" + "version_" + _pagkageName + ".manifest",
		"version": version
	}
	for (var i = 0; i < filesList.length; ++i) {
		var file = filesList[i];
		obj.assets[file.name] = {
					"md5" : file.md5,
					"path" : file.path,
					"size" : file.size
					}
	}
	
	var strManifest = JSON.stringify(obj); 	
	fs.writeFile(_outDir + "/project_" + _pagkageName + ".manifest", strManifest, 'utf-8', function () {
		console.log("project_" + _pagkageName + ".manifest 生成成功");
	});
}

write2manifest();

function write2versionmanifest() {
	var obj = {
			"packageUrl" : url,
			"remoteManifestUrl": url + "manifests/" + "project_" + _pagkageName + ".manifest",
			"remoteVersionUrl": url + "manifests/" + "version_" + _pagkageName + ".manifest",
			"version": version
		}	
	var strManifest = JSON.stringify(obj); 	
	fs.writeFile(_outDir + "/version_" + _pagkageName + ".manifest", strManifest, 'utf-8', function () {
		console.log("version_" + _pagkageName + ".manifest 生成成功");
	});
}

write2versionmanifest();