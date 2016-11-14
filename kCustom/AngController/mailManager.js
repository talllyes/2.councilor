app.controller('mailManager', function ($scope, $http, $routeParams, $filter) {
    var mailManager = this;
    mailManager.mailSendNow = false;
    mailManager.updateMailFlag = true;
    mailManager.noSendList = "";
    mailManager.yesSendList = "";
    mailManager.selectNoSend = "";
    mailManager.selectYesSend = "";
    mailManager.mailConfig = "";
    mailManager.updateSendMailFlag = true;
    mailManager.mailConfigTemp = "";
    mailManager.mailSetBox = true;
    mailManager.mailSet1= true;
    mailManager.mailSet2 = true;

    //宣告KaiSearch
    mailManager.myPage = new kaiSearch({
        controllerScope: $scope,
        controllerName: 'mailManager.myPage',
        maxSize: 5,
        itemsPerPage: 10
    });

    function getMailLogList() {
        $http({
            method: 'GET',
            url: "api/GetPostManager/MailLog"
        }).success(function (data, status, headers, config) {
            mailManager.myPage.setData(data);
        }).error(function (data, status, headers, config) {
        });
    }
    getMailLogList();




    mailManager.insertSend = function (type) {
        mailManager.updateSendMailFlag = true;
        var out = [];
        angular.forEach(mailManager.noSendList[type], function (temp, key) {
            var flag = true;
            angular.forEach(mailManager.selectNoSend[type], function (temp2, key) {
                if (temp.UserLoginID == temp2.UserLoginID) {
                    flag = false;
                }
            });
            if (flag) {
                out.push(temp);
            } else {
                mailManager.yesSendList[type].push(temp);
            }
        })
        mailManager.noSendList[type] = out;
        $http({
            method: 'POST',
            url: "api/GetPostManager/UpdateSendName",
            data: mailManager.yesSendList[type]
        }).success(function (data, status, headers, config) {
            mailManager.updateSendMailFlag = false;
        }).error(function (data, status, headers, config) {
        });
    }

    mailManager.deleteSend = function (type) {
        mailManager.updateSendMailFlag = true;
        var out = [];
        angular.forEach(mailManager.yesSendList[type], function (temp, key) {
            var flag = true;
            angular.forEach(mailManager.selectYesSend[type], function (temp2, key) {
                if (temp.UserLoginID == temp2.UserLoginID) {
                    flag = false;
                }
            });
            if (flag) {
                out.push(temp);
            } else {
                mailManager.noSendList[type].push(temp);
            }
        })
        mailManager.yesSendList[type] = out;
        if ($.isEmptyObject(mailManager.yesSendList[type])) {
            var n = "3";
            if (type == 0) {
                n = "3";
            } else {
                n = "7";
            }
            $http({
                method: 'POST',
                url: "api/GetPostManager/UpdateSendNameNull",
                data: n
            }).success(function (data, status, headers, config) {
                mailManager.updateSendMailFlag = false;
            }).error(function (data, status, headers, config) {
            });
        } else {
            $http({
                method: 'POST',
                url: "api/GetPostManager/UpdateSendName",
                data: mailManager.yesSendList[type]
            }).success(function (data, status, headers, config) {
                mailManager.updateSendMailFlag = false;
            }).error(function (data, status, headers, config) {
            });
        }
    }


    mailManager.getMailConfig = function () {
        $http({
            method: 'GET',
            url: "api/GetPostManager/MailConfig",
        }).success(function (data, status, headers, config) {
            mailManager.mailConfig = data.MailConfig;
            mailManager.yesSendList = data.Send.YesSend;
            mailManager.noSendList = data.Send.NoSend;
            mailManager.updateSendMailFlag = false;
        }).error(function (data, status, headers, config) {
        });
    }

    mailManager.getMailConfig();
    mailManager.mailToSend = function (type) {
        mailManager.mailSendNow = true;
        if (type == 0) {
            $http({
                method: 'POST',
                url: "api/GetPostCase/MailToSend",
                data: "0"
            }).success(function (data, status, headers, config) {
                mailManager.mailSendNow = false;
                getMailLogList();
            }).error(function (data, status, headers, config) {
            });
        } else if (type == 3) {
            $http({
                method: 'POST',
                url: "api/GetPostCase/MailToSend",
                data: "3"
            }).success(function (data, status, headers, config) {
                mailManager.mailSendNow = false;
                getMailLogList();
            }).error(function (data, status, headers, config) {
               
            });
        } else if (type == 7) {
            $http({
                method: 'POST',
                url: "api/GetPostCase/MailToSend",
                data: "7"
            }).success(function (data, status, headers, config) {
                mailManager.mailSendNow = false;
                getMailLogList();
            }).error(function (data, status, headers, config) {
            });
        }
    }

    mailManager.updateMail = function (type) {
        if (type == "edit") {
            mailManager.updateMailFlag = false;
            mailManager.mailConfigTemp = angular.copy(mailManager.mailConfig);
        } else if (type == "ok") {            
            mailManager.updateMailFlag = true;
            $http({
                method: 'POST',
                url: "api/GetPostManager/UpdateMailConfig",
                data: mailManager.mailConfig
            }).success(function (data, status, headers, config) {
            }).error(function (data, status, headers, config) {
            });
        } else if (type == "no") {
            angular.copy(mailManager.mailConfigTemp,mailManager.mailConfig);
            mailManager.updateMailFlag = true;
        }
    }
})


