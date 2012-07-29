
/*
VERSION: 1.01
DATE: JULY 11, 2012
ACTIONSCRIPT VERSION: 3.0 (AS2 version is available upon request)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://vvvote.com 

DESCRIPTION: 

vvvote is a secure, managable voting system. 
Suitable for competitions and internet projects that may need moderation 
and/or facebook+twitter tallies.

The items being voted on can grow as time goes by. It is flexible.

You can define the day that the voting begins and also define when voting closes.

You can restrict the votes by 
- cookie (automatically recorded), 
- ip address (automatically recorded), 
- email address (user submitted), or 
- phone number (user submitted)

You can vote up (+1), or vote down (-1), or vote with no value (0, for initialising the item)


In terms of development, the primary unique identifier is 
external_reference_string

This string can be a url, person's name, location, vegetables, anything! 

-----------------
VEGETABLE EXAMPLE (it doesn't need to be vegetables!)
-----------------

You have four vegetables to vote on
+ tomato
+ egg plant
+ strawberry
+ lemon

Users can vote on these vegetables

+ tomato (543)
+ egg plant (687)
+ strawberry (257)
+ lemon (541)

You can reference the tally whenever you want, as a feed.
You can order the list by the number of votes

1. egg plant (687)
2. tomato (543)
3. lemon (541)
4. strawberry (257)

Then you can automatically add a new vegetable to vote on, when a new vegetables appears. 
You don't need to manually create this new vegetables

1. egg plant (687)
2. tomato (543)
3. lemon (541)
4. strawberry (257)
5. mango (2)


You can also add properties to each object


------------------------
VARIABLE PROPERTY LIST:
------------------------
page_title
page_summary
page_image_url
external_reference_id (int)
detail_MessageId
detail_ImageFile
detail_ImageDescription
detail_DateReceived
detail_Name
detail_FirstName
detail_LastName
detail_HomePhoneNumber
detail_EmailAddress
detail_Address
detail_Suburb
detail_Postcode
detail_State
detail_DateOfBirth
detail_Gen1
detail_Gen2
detail_Gen3
detail_Gen4
detail_Gen5
detail_Gen6
detail_Gen7
detail_Gen8
detail_Gen9
detail_Gen10

These properties appear in the in the feeds.

You can encrypt these properties, so they are not stored on the database and don't appear in the XML.

All feeds can be requested in XML, JSON or HTML.


AUTHOR: Paul Casey, paul@paulcasey.net
Copyright 2012, Paul Casey Service. All rights reserved. This work is subject to the terms in http://vvvote.com/terms_of_use.html 

*/

package com.vvvote {
	
	import flash.events.DataEvent;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.events.SecurityErrorEvent;
	import flash.events.HTTPStatusEvent;
	import flash.system.Security;
	

	public class VvvoteService extends EventDispatcher {
		
		static public const VVVOTE_KEY_SUCCESS:String = "VVVOTE_KEY_SUCCESS";
		static public const VVVOTE_VOTING_COMPLETE_AND_VALID:String = "VVVOTE_VOTING_COMPLETE_AND_VALID";
		static public const VVVOTE_VOTING_COMPLETE_AND_NOT_VALID:String = "VVVOTE_VOTING_COMPLETE_AND_NOT_VALID";	
		static public const VVVOTE_VOTE_COUNT_REQUEST_COMPLETE:String = "VVVOTE_VOTE_COUNT_REQUEST_COMPLETE";	
		static public const VVVOTE_SUCCESS:String = "VVVOTE_SUCCESS";
		static public const VVVOTE_ERROR:String = "VVVOTE_ERROR";
		static public const VVVOTE_IOERROR:String = "VVVOTE_IOERROR";
		
		
		// Vvvote service config
		private const _SERVICE_URL:String = "http://vvvote.com/api/service";
		
		// defines variable for loading data
		private var _dataLoader:URLLoader;
		
		// variables that are defined in defineProjectSettings();
		private var _projectName:String;
		private var _projectPassword:String;
		private var _debugMode:Boolean;
		private var _externalReferenceString:String;
		private var _vote_value:Number;
		private var _vars:Object;
		private var _voter_email:String;
		private var _voter_phone_number:String;
		
		public var _responseXML:XML;
		
		/**
		 * Defines the project
		 * @param	$projectName: name for the project (please refer to http://vvvote.com/admin/[your-project]/home)
		 * @param	$projectPassword: password for the project (please refer to http://vvvote.com/admin/[your-project]/home)
		 */
		public function defineProjectSettings($projectName:String, $projectPassword:String, $debugMode:Boolean = false):void {
			_projectName = $projectName;
			_projectPassword = $projectPassword
			_debugMode = $debugMode
		}
		
		/**
		 * Gets a vote key, to begin voting
		 * you must define the project settings first: 
		 * defineProjectSettings($projectName, $projectPassword) 
		 * @param	$external_reference_string: this is the primary identifier for your votes. This must be unique for each item users are voting on. This is what identifies what votes are tallied against. This can be any string, including numbers and spaces.
		 * @param	$voting_vote_value: this is the vote value. You can vote up (+1), or vote down (-1), or vote with no value (0, for initialising the item). Any other numbers will not be inserted into the datablase (eg: 14 will not be recorded).
		 * @param	$vars: these are the properties associated with the primary identifier. A full list of properties and description can be viewed at the top of this class.
		 * @param	$voter_email: this is only relevant to projects that restrict the number of votes a user can vote on, by the email they submit. These projects are pretty rare, so if you are not sure about this, then it probably doesn't apply to you.
		 * @param	$voter_phone_number: this is only relevant to projects that restrict the number of votes a user can vote on, by the phone number they submit. These projects are pretty rare, so if you are not sure about this, then it probably doesn't apply to you.
		 */
		public function initVotingForAnItem($external_reference_string:String, $vote_value:Number = 1, $vars:Object = null, $voter_email:String = "", $voter_phone_number:String = ""):void {
			
			// defines the url
			_externalReferenceString = $external_reference_string;
			// define the object of vars
			_vars = $vars;
			// define the voting value (1, -1, or 0)
			_vote_value = $vote_value;
			// define the detailes of the user who is voting (these are rarely required)
			_voter_email = $voter_email;
			_voter_phone_number = $voter_phone_number;
			
			if (_projectName.length < 1 || _projectPassword.length < 1) {
				// NO PROJECT NAME OR PROJECT PASSWORD IS DEFINED
				trace("----------------------------------------------------")
				trace("VvvotingService.as ErrorMessage: you must define the defineProjectSettings($projectName, projectPassword)")
				trace("VvvotingService.as ErrorMessage: please refer to http://vvvote.com/admin/[your-project]/home")
				trace("----------------------------------------------------")
				
			} else {
				// PROJECT NAME AND PROJECT PASSWORD ARE DEFINED
				// references the previously defined name and password
				var $projectName = _projectName;
				var $projectPassword = _projectPassword;
				
				var sendString:String = "project_name="+$projectName+"&project_password="+$projectPassword+"&cacheKiller="+Math.random()*1000;			
				
				if(_debugMode) trace("VVVOTE REQUESTING A KEY FOR SECURITY: "+_SERVICE_URL+"/key_to_vote/?"+sendString)
				
				// Get the data
				var request:URLRequest = new URLRequest(_SERVICE_URL+"/key_to_vote/");
				request.method = URLRequestMethod.GET;
				request.data = sendString;
				
				connect();
				
				_dataLoader.load(request);
			}
			
		}
		
		public function voteForAnItemWithNewKey(e:Event):void {
			var _responseXML:XML = new XML(unescape(_dataLoader.data))
			if (_responseXML..VotingKey.length() > 0) {
				// VOTING KEY RESPONSE WORKED
				
				// references the previously defined name and password
				var $projectName = _projectName;
				var $projectPassword = _projectPassword;
				
				// refers to the key in the xml
				var $votingKey = _responseXML..VotingKey;
				
				// adds all the item properties to the sendString
				var propertiesStr:String = "";
				for ( var i:String in _vars) {
					propertiesStr += "&" + i + "=" + _vars[i];
				}
				
				// adds the voting users' details to the sendString
				var voter_details:String = "";
				if (_voter_email != "") {
					voter_details += "&voter_email="+_voter_email;
				}
				if (_voter_phone_number != "") {
					voter_details += "&voter_phone_number="+_voter_phone_number;
				}
				
				var sendString:String = "voting_key="+$votingKey+"&project_name="+$projectName+"&project_password="+$projectPassword+"&external_reference_string="+_externalReferenceString+"&vote_value="+_vote_value+""+voter_details+""+propertiesStr+"&cacheKiller="+Math.random()*1000;			
				
				if(_debugMode) trace("VVVOTE ACTIVATING VOTE USING KEY: "+_SERVICE_URL + "/vote_on_item/?" + sendString)
				
				// Get the data
				var request:URLRequest = new URLRequest(_SERVICE_URL+"/vote_on_item/");
				request.method = URLRequestMethod.GET;
				request.data = sendString;
				
				connect();
				
				_dataLoader.load(request);
				
				
			} else {
				// VOTING KEY RESPONSE INVALID
				trace("----------------------------------------------------")
				trace("XML ErrorMessage: "+_responseXML..ErrorMessage)
				trace("----------------------------------------------------")
				
			}
		}
		
		
		
		/**
		 * Gets a vote count on an item
		 * you must define the project settings first: 
		 * defineProjectSettings($projectName, $projectPassword) 
		 * @param	$external_reference_string: this is the primary identifier for your votes. This must be unique for each item users are voting on. This is what identifies what votes are tallied against. This can be any string, including numbers and spaces.
		 */
		public function initVoteCountRequestForAnItem($external_reference_string:String):void {
			
			// defines the url
			_externalReferenceString = $external_reference_string;
			
			if (_projectName.length < 1 || _projectPassword.length < 1) {
				// NO PROJECT NAME OR PROJECT PASSWORD IS DEFINED
				trace("----------------------------------------------------")
				trace("VvvotingService.as ErrorMessage: you must define the defineProjectSettings($projectName, projectPassword)")
				trace("VvvotingService.as ErrorMessage: please refer to http://vvvote.com/admin/[your-project]/home")
				trace("----------------------------------------------------")
				
			} else {
				// PROJECT NAME AND PROJECT PASSWORD ARE DEFINED
				// references the previously defined name and password
				var $projectName = _projectName;
				var $projectPassword = _projectPassword;
				
				var sendString:String = "external_reference_string="+$external_reference_string+"&project_name="+$projectName+"&project_password="+$projectPassword+"&cacheKiller="+Math.random()*1000;			
				
				if(_debugMode) trace("VVVOTE REQUESTING A VOTE COUNT FOR AN ITEM: "+_SERVICE_URL+"/vote_count/?"+sendString)
				
				// Get the data
				var request:URLRequest = new URLRequest(_SERVICE_URL+"/vote_count/");
				request.method = URLRequestMethod.GET;
				request.data = sendString;
				connect();
				
				_dataLoader.load(request);
			}
			
		}
		
		
		/**
		 * Get gallery
		 * @param	$batch: index of the current page
		 * @param	$size: amount of picture per page
		 */
		
		 
		 
		 
		public function getVvvoteDetails():void {
			
			var sendString:String = "id=1"+"&cacheKiller="+Math.random()*1000;			
			
			// Get the data
			var request:URLRequest = new URLRequest(_SERVICE_URL+"/user/");
			request.method = URLRequestMethod.GET;
			request.data = sendString;
			
			connect();
			
			_dataLoader.load(request);
		}
		
		
		
		/////////////////////////////////////
		// Private functions - helper methods
		/////////////////////////////////////
		private function connect():void
		{
			dispose();
			
			_dataLoader = new URLLoader();
			_dataLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
			_dataLoader.addEventListener(Event.COMPLETE, successHandler, false, 0, true);
			_dataLoader.addEventListener(ProgressEvent.PROGRESS, progressListener, false, 0, true);
			_dataLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorListener, false, 0, true);
			_dataLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorListener, false, 0, true);
            _dataLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusListener, false, 0, true);
		}
		
		/**
		 * Clean the listeners
		 */
		private function dispose():void
		{
			if (_dataLoader)
			{
				_dataLoader.removeEventListener(Event.COMPLETE, successHandler, false);
				_dataLoader.removeEventListener(ProgressEvent.PROGRESS, progressListener, false);
				_dataLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorListener, false);
				_dataLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorListener, false);
				_dataLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusListener, false);
			}
		}
		
		/**
		 * Success Handler
		 * @param	e
		 */
		private function successHandler(e:Event):void
		{
			_responseXML = new XML(unescape(_dataLoader.data));
			
			if(_debugMode) trace(_responseXML)
			
			// VOTING RESPONSES
			if (_responseXML..VotingKey.length() > 0) {
				// DISPATCHES AN EVENT SAYING THE KEY HAS LOADED
				dispatchEvent(new Event(VVVOTE_KEY_SUCCESS));
				
			} else if (_responseXML..Response == "ValidVote") {
				// DISPATCHES AN EVENT SAYING THE KEY HAS LOADED
				dispatchEvent(new Event(VVVOTE_VOTING_COMPLETE_AND_VALID));
				
			} else if (_responseXML..Response == "InvalidVote") {
				// DISPATCHES AN EVENT SAYING THE KEY HAS LOADED
				dispatchEvent(new Event(VVVOTE_VOTING_COMPLETE_AND_NOT_VALID));
				
			} else if (_responseXML..vote_count) {
				// DISPATCHES AN EVENT SAYING THE VOTE COUNT LOADED
				dispatchEvent(new Event(VVVOTE_VOTE_COUNT_REQUEST_COMPLETE));
				
			}
			
			// Dispatch the success event as it's the responsibility of the caller to check the XML result
			// For example the get gallery code does not countain any Status attribute
			dispatchEvent(new Event(VVVOTE_SUCCESS));
			
		}
		
		/** 
		 * Other Handlers
		 */
		private function securityErrorListener(e:SecurityErrorEvent):void 
		{
			trace("securityErrorListener: " + e);
			dispatchEvent(new Event(VVVOTE_ERROR));
		}
		
		private function httpStatusListener(e:HTTPStatusEvent):void 
		{
			if(_debugMode) trace("httpStatusListener: " + e);
		}
		
		private function progressListener(e:ProgressEvent):void 
		{
			var loaded:Number = e.bytesLoaded;
			var total:Number = e.bytesTotal;
			
			if(_debugMode) trace("progressListener: loaded: " + loaded + " | total: " + total);
		}
		
		private function ioErrorListener(e:IOErrorEvent):void 
		{
			trace("ioErrorListener: " + e);
			if (_dataLoader.data) {
				_responseXML = new XML(unescape(_dataLoader.data));
			}
			dispatchEvent(new Event(VVVOTE_ERROR));
			dispatchEvent(new Event(VVVOTE_IOERROR));
		}
		
		
		
	}
}
	
