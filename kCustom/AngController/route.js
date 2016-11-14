app.config(function ($routeProvider, $locationProvider) {
    $routeProvider
     .when('/home', {
         templateUrl: 'template/home.html',
         controller: 'home as home'
     })
    .when('/newCase', {
        templateUrl: 'template/newCase.html',
        controller: 'newCase as newCase'
    })
    .when('/caseList/:type', {
        templateUrl: 'template/caseList.html',
        controller: 'caseList as caseList'
    })
    .when('/searchCase/:type', {
        templateUrl: 'template/searchCase.html',
        controller: 'searchCase as searchCase'
    })
    .when('/userManager', {
        templateUrl: 'template/userManager.html',
        controller: 'userManager as userManager'
    })
    .when('/councilorManager', {
        templateUrl: 'template/councilorManager.html',
        controller: 'councilorManager as councilorManager'
    })
    .when('/zoneManager', {
        templateUrl: 'template/zoneManager.html',
        controller: 'zoneManager as zoneManager'
    })
    .when('/mailManager', {
        templateUrl: 'template/mailManager.html',
        controller: 'mailManager as mailManager'
    })
    .when('/jobTitleManager', {
        templateUrl: 'template/jobTitleManager.html',
        controller: 'jobTitleManager as jobTitleManager'
    })
    .otherwise({
        redirectTo: '/home'
    });
});

