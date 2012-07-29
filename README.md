[vvvote](http://vvvote.com/) - flexible and secure voting API
==================================================


vvvote is a secure, managable voting system. 
Suitable for competitions and internet projects that may need moderation 
and/or facebook+twitter tallies.

The items being voted on can grow as time goes by. It is flexible.

You can define the day that the voting begins and also define when voting closes.

You can restrict the votes by 
--------------------------------------
- cookie (automatically recorded), 
- ip address (automatically recorded), 
- email address (user submitted), or 
- phone number (user submitted)

You can vote up (+1), or vote down (-1), or vote with no value (0, for initialising the item)


In terms of development, the primary unique identifier is 
external_reference_string

This string can be a url, person's name, location, vegetables, anything! 


VEGETABLE EXAMPLE (it doesn't need to be vegetables!)
--------------------------------------

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



VARIABLE PROPERTY LIST:
--------------------------------------
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
