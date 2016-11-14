//\n轉Br
app.filter('toSpace', function () {
    return function (str, key) {
        if (key == "br") {
            if (str != "" && str != null) {
                str = str.replace(/\<br \/>/g, "\n");
                return str;
            } else {
                return "";
            }
        } else if (key == "n") {
            if (str != "" && str != null) {
                str = str.replace(/\n/g, "<br />");
                return str;
            } else {
                return "";
            }
        } else if (key == "n2") {
            if (str != "" && str != null) {
                str = str.replace(/\n/g, "<br />　　　　　");
                return str;
            } else {
                return "";
            }
        } else {
            return str;
        }
    };
});

app.filter('endCase', function () {
    return function (input, key) {
        if (input != "") {
            return "";
        } else {
            return "display:none;";
        }
    }
});

app.filter('numberTranslateText', function () {
    return function (input, key) {
        if (key == "1") {
            if (input == "1") {
                return "號誌股";
            } else if (input == "2") {
                return "交控股";
            }
        } else if (key == "2") {
            if (input == "1") {
                return "啟用中";
            } else if (input == "0") {
                return "停用中";
            } else if (input == "3") {
                return "管理員";
            }
        } else if (key == "3") {
            if (input == "1") {
                return "議員";
            } else if (input == "2") {
                return "立委";
            } else if (input == "3") {
                return "里長";
            }
        } else if (key == "4") {
            if (input == "1") {
                return "普通";
            } else if (input == "2") {
                return "年度計劃";
            }
        } else {
            return "無";
        }
    }
});

app.filter('overDay', function () {
    return function (input, key) {
        if (input.indexOf("逾") != -1) {
            return "kai-red";
        } else if (input.indexOf("年度") != -1) {
            return "kai-red";
        } else if (input.indexOf("除管") != -1) {
            return "kai-green";
        } else {
            return "";
        }
    }
});
app.filter('mailType', function () {
    return function (input, key) {
        if (input == "0") {
            return "寄稽催信給承辦人";
        } else if (input == "3") {
            return "寄3天未辦理案件";
        } else if (input == "7") {
            return "寄7天未辦理案件";
        }
    }
});
app.filter('searchState', function () {
    return function (input, key) {
        if (input == "") {
            return "普通";
        } else {
            return input;
        }
    }
});
