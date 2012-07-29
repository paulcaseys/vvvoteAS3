package {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	// imports vvvote service
	import com.vvvote.VvvoteService;
	
	/**
	 * Simple actionscript example of the vvvote system
	 * http://vvvote.com 
	 * vvvote was created by
	 * http://paulcasey.net
	 * @author Paul Casey
	 */
	public class Example extends MovieClip {
		
		// defines vvvote service variable for voting on an item
		private var _vvvoteServiceVoteForAnItem:VvvoteService;
		private var _vvvoteServiceVoteCountRequestForAnItem:VvvoteService;
		
		// defines the project settings				EDIT THESE TWO VARIABLES
		private var _vvvoteProjectName:String 		= "demoProject";
		private var _vvvoteProjectPassword:String 	= "D4B6D44EE68D124D81DAAE9E59747";
		
		/**
		 * Constructor
		 */
		public function Example() {
			vote();
			requestVoteCount();
		}
		
		
		/**
		 * Voting on an item
		 */
		private function vote():void {
			
			// votes for an item
			_vvvoteServiceVoteForAnItem = new VvvoteService();
			_vvvoteServiceVoteForAnItem.defineProjectSettings(_vvvoteProjectName, _vvvoteProjectPassword, false);
			_vvvoteServiceVoteForAnItem.addEventListener(VvvoteService.VVVOTE_KEY_SUCCESS, _vvvoteServiceVoteForAnItem.voteForAnItemWithNewKey);
			_vvvoteServiceVoteForAnItem.addEventListener(VvvoteService.VVVOTE_VOTING_COMPLETE_AND_VALID, voteCompleteSuccessHandler);
			_vvvoteServiceVoteForAnItem.addEventListener(VvvoteService.VVVOTE_VOTING_COMPLETE_AND_NOT_VALID, voteCompleteNotValidHandler);
			_vvvoteServiceVoteForAnItem.addEventListener(VvvoteService.VVVOTE_ERROR, voteErrorHandler);
			_vvvoteServiceVoteForAnItem.initVotingForAnItem("tomato", +1, {page_title:"Tomatoes are delicious", page_summary:"The tomato fruit is consumed in diverse ways, including raw, as an ingredient in many dishes and sauces, and in drinks."});	
						
		}
		
		/**
		 * Vote count request
		 */
		private function requestVoteCount():void {
			
			// requests a vote count tally on an item
			_vvvoteServiceVoteCountRequestForAnItem = new VvvoteService();
			_vvvoteServiceVoteCountRequestForAnItem.defineProjectSettings(_vvvoteProjectName, _vvvoteProjectPassword, false);
			_vvvoteServiceVoteCountRequestForAnItem.addEventListener(VvvoteService.VVVOTE_VOTE_COUNT_REQUEST_COMPLETE, voteCountRequestCompleteSuccessHandler);
			_vvvoteServiceVoteCountRequestForAnItem.addEventListener(VvvoteService.VVVOTE_ERROR, voteCountRequestErrorHandler);
			_vvvoteServiceVoteCountRequestForAnItem.initVoteCountRequestForAnItem("tomato");	
			
		}
		
		
		/** 
		 * VOTE EVENT HANDELERS
		 */
		
		/** 
		 * Vote entry was completely successful
		 */
		private function voteCompleteSuccessHandler(e:Event):void {
			trace("VOTE SUCCESSFUL AND VALID");	
			
			// the XML request results 		
			var result:XML = _vvvoteServiceVoteForAnItem._responseXML.copy();
			var vote_count:Number = Number(result..vote_count);
			
		}
		
		/** 
		 * Vote entry was successful, but the vote was invalid (due to exceeding the limits of ip/cookie/email/ph in the project settings)
		 */
		private function voteCompleteNotValidHandler(e:Event):void {			
			trace("VOTE SUCCESSFUL BUT NOT VALID: use the defineProjectSettings debug mode to view reason, or trace inactive_reason below");
			
			// the XML request results 
			var result:XML = _vvvoteServiceVoteForAnItem._responseXML.copy();
			var vote_count:Number = Number(result..vote_count);
			var inactive_reason:String = result..inactive_reason;
			
		}
		
		/** 
		 * Vote entry was NOT successful, due to user internet failure, disconnection or server failure
		 */
		private function voteErrorHandler(e:Event):void {
			trace("VOTE CRITICALLY UNSUCCESSFUL");
			
		}
		
		/** 
		 * Vote count request was successful
		 */
		private function voteCountRequestCompleteSuccessHandler(e:Event):void {
			trace("VOTE COUNT REQUEST COMPLETE");
			
			// the XML request results 
			var result:XML = _vvvoteServiceVoteCountRequestForAnItem._responseXML.copy();
			var vote_count:Number = Number(result..vote_count);
			
		}
		
		/** 
		 * Vote count request was NOT successful, due to user internet failure, disconnection or server failure
		 */
		private function voteCountRequestErrorHandler(e:Event):void {
			trace("VOTE COUNT REQUEST CRITICALLY UNSUCCESSFUL");
			
		}
		
		
			
		
		
		
		
	}
}
