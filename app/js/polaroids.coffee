wowstagram = angular.module "wowstagram", ['ui.router']

wowstagram.constant 'LOCALES', ->
  us: ['en_US', 'es_MX', 'pt_BR']
  eu: ['de_DE', 'en_GB', 'es_ES', 'fr_FR', 'it_IT', 'ru_RU']

wowstagram.factory 'WowRealmStatusService', ($http, $q) ->
  deferred = $q.defer()

  getRealms: ->
    if realms = JSON.parse localStorage.getItem('wowstagram:realms')
      deferred.resolve(realms)
    else
      euRealms = $http.jsonp("http://us.battle.net/api/wow/realm/status?jsonp=JSON_CALLBACK")
      usRealms = $http.jsonp("http://eu.battle.net/api/wow/realm/status?jsonp=JSON_CALLBACK")
      $q.all([euRealms, usRealms]).then (statuses) ->
        combinedStatuses = {realms: _.union(statuses[0].data.realms, statuses[1].data.realms)}
        localStorage.setItem 'wowstagram:realms', JSON.stringify(combinedStatuses)
        deferred.resolve(combinedStatuses)

    deferred.promise

wowstagram.config ($stateProvider, $urlRouterProvider) ->

  $urlRouterProvider.otherwise "/home"

  $stateProvider.state 'home',
    url: '/home'
    controller: 'FormController'
    resolve:
      WowRealms: (WowRealmStatusService) -> WowRealmStatusService.getRealms()

wowstagram.controller "FormController", ($scope, $http, WowRealms) ->

  window.realms = WowRealms.realms

  $scope.localeOptions = _(WowRealms.realms).chain().pluck('locale').unique().map((l) -> {value: l}).value()

  $scope.toon =
    server: 'bleeding-hollow'
    name: 'chosen'
    locale: 'us'

  $scope.fetchPicture = ->
    url = "http://us.battle.net/api/wow/character/#{$scope.toon.server}/#{$scope.toon.name}?jsonp=JSON_CALLBACK"
    $http.jsonp(url).success (data) ->
      profilemain = "http://#{$scope.toon.locale}.battle.net/static-render/#{$scope.toon.locale}/#{data.thumbnail.replace('avatar', 'profilemain')}"
      $('#polaroid').find('img').attr('src', profilemain)


