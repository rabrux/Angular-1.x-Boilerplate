angular
  .module('app')
  .config [
    '$stateProvider'
    '$urlRouterProvider'
    ($stateProvider, $urlRouterProvider) ->

      $urlRouterProvider.otherwise '/'

      $stateProvider
        .state('home',
          url: '/'
          templateUrl: 'templates/home/index.html'
          # controller: 'HomeCtrl'
        )

      return
  ]
