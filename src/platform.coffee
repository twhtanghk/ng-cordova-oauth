$ = require 'jquery'
$.deparam = require 'jquery-deparam'

angular.module('oauth.platform', ['ionic', 'ngCordova', 'oauth.utils'])

	.config ($cordovaInAppBrowserProvider) ->
		
		document.addEventListener 'deviceready', ->
			$cordovaInAppBrowserProvider.setDefaultOptions
				location: 'no'
				clearsessioncache: 'yes'
				clearcache: 'yes'
				toolbar: 'no'

	.factory 'platformService', ($rootScope, $cordovaDevice, $ionicModal, $q, $cordovaOauthUtility, $cordovaInAppBrowser) ->
		
		open: (url) ->
			deferred = $q.defer()
			
			document.addEventListener 'deviceready', ->
				check = (url, close) ->
					if url.match(/error|access_token/)
						path = new URL(url)
						data = $.deparam /(?:[#\/]*)(.*)/.exec(path.hash)[1]	# remove leading / or #
						err = $.deparam /\?*(.*)/.exec(path.search)[1]			# remove leading ?
						if err.error
							close()
							deferred.reject err
						else
							close()
							deferred.resolve data
							
				switch $cordovaDevice.getPlatform()
				
					when 'browser'
						# child window post message with data or error
						$rootScope.modal = $ionicModal.fromTemplate """
							<ion-modal-view>
								<ion-content>
									<iframe src='#{url}'>
									</iframe>
								</ion-content>
							</ion-modal-view>
						"""
						
						# parent window listen if child url is updated
						window.addEventListener 'message', (event) ->
							check event.data, ->
								$rootScope.modal.remove()
							
						$rootScope.modal.show()
						
					else
						cordovaMetadata = cordova.require("cordova/plugin_list").metadata
						if $cordovaOauthUtility.isInAppBrowserInstalled(cordovaMetadata)
							$rootScope.$on '$cordovaInAppBrowser:loadstart', (e, event) ->
								check(event.url, $cordovaInAppBrowser.close)
							$rootScope.$on '$cordovaInAppBrowser:exit', (e, event) ->
								check('error', $cordovaInAppBrowser.close)
							document.addEventListener 'deviceready', ->
								$cordovaInAppBrowser.open url, '_blank'
						else
							deferred.reject("Could not find InAppBrowser plugin")
			
			return deferred.promise