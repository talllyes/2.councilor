app.controller('home', function ($scope, $http) {
    var home = this;
    home.caseNum = "";
    home.getHome = function () {
        $http({
            method: 'GET',
            url: "api/GetPostCase/Home",
        }).success(function (data, status, headers, config) {
            home.caseNum = data;
            $(".caseListItem").css("display", "");
            $(".caseListItem").animate({ opacity: 1 }, 700);
        }).error(function (data, status, headers, config) {
        });
    }

    home.getHome();
})