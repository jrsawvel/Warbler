# Warbler

Warbler is a message board where all thread starter posts and comments are Webmentions.

A Webmention is a cross-site communication idea, espoused by the IndieWeb community. Webmentions can be used as a commenting system and for other functions, such as distributing shares, likes, bookmarks, RSVPs, and more across websites. 

For example, users can create RSVP-type posts on their websites, and then their publishing apps can send the RSPV Webmentions to the website that announced the event, provided that the site accepts Webmentions.

Some websites receive Webmentions by displaying text input fields, and authors can manually copy the URLs to their posts and paste them into the text input fields.

A Webmention post is considered the source URL. This post must contain the URL of the post that the author is responding to, which is called the target URL.

A protocol describes how Webmentions are sent and received, but website owners who receive Webmentions decide how to display them.

More info about the Webmention can be found at: 

* <https://indieweb.org/webmention>
* <https://webmention.net>

From the IndieWeb:

> Webmention is a web standard for mentions and conversations across the web, a powerful building block that is used for a growing federated network of comments, likes, reposts, and other rich interactions across the decentralized social web.

To reduce abuse by spammers and trolls, the IndieWeb community recommends iplementing the Vouch protocol with Webmention.

* <http://indieweb.org/Vouch> 

> The Vouch protocol is an anti-spam extension to Webmention

Warbler does not use Vouch.

Some personal website authors moderate the Webmentions that they have receive before allowing them to be displayed.

The spec found at <https://www.w3.org/TR/webmention> states:

> The Webmention endpoint will validate and process the request, and return an HTTP status code [RFC7231]. Most often, 202 Accepted or 201 Created will be returned, indicating that **the request is queued and being processed asynchronously** to prevent DoS (Denial of Service) attacks. 

Processing a recevied Webmention asynchronously is a suggestion. Warbler does not do this either

Warbler implements throttling for the entire website and for each author's domain name.

The test website is found at <http://warbler.soupmode.com>.

A post from any domain name is accepted at most once every 60 seconds.

A post from any author's domain name is accepted at most once every five minutes.

Warbler offers a Webmention endpoint. Some web publishing apps can programmatically send Webmentions. The Warbler Webmention endpoint is listed within each web page. A user can also use the cUrl command-line tool to send Webmentions to Warbler's endpoint.

Other barriers could be used, such as removing the endpoint and requiring all Webmentions to be posted manually by copying and pasting the URLs into text input fields at the Warbler site. Of course, this action can be scripted.

An additional barrier would be to require each post to log into the Warbler site by using IndieAuth. More info about IndieAuth can be found at:

* <http://indieweb.org/indieauth>

IndieAuth requires an additional layor of "work" by the users who want to post to a Warbler message board. They must be logged into another service, such as GitHub, Twitter, Facebook, etc., and their personal websites must point to their social media accounts, and their social media accounts must point to their personal websites.

Nearly everything can be scripted. None of these ideas completely deter determined trolls and spammers, but innovating more barriers can help. If the goal is to create a community, then real community users won't mind the barriers. More is not always better.

In my opinion, a Webmention-based message board or commenting system can lead to better quality discussions. 

If a publisher simply no longer wants to accept contributions of any type from other users, then that's a good reason to disable comments.

But if the reason for disabling comments is because the comment sections have become too toxic and/or because most of the discussions occur on social media, then those are not good reasons to disable comments.

Facebook's real-name policy has not made comments more civil. Toxic comments occur frequently at Twitter, and Twitter's 140-character limitation makes is nearly useless as a legitimate commenting sytesm. Tweetstorms and posting blobs of text as an image attachment are horrible solutions for circumventing Twitter's character limit.

The idea of comments or user-contributed content is not the problem. It seems to me that many publishers blame the concept of comments as a reason why discussion turn toxic. In my opinion, the failure or the blame belongs to the publishers for not innovating ways to create a worthwhile community.

If the goal is to increase page views, then publishers will use few to no barriers to entry, and this could lead to messy discussions. From my experience at managing the small message board <http://toledotalk.com>, since January 2003, the more barriers, the better the discussions, which leads to a more respectful community.




