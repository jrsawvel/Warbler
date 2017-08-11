# Warbler README.md

Warbler is a message board where all thread starter posts and comments are Webmentions.

A Webmention is a cross-site communication idea, espoused by the IndieWeb community. It may remind some of the trackback and pingback functionality that many blog sites offered back in the aught years.

Webmentions can be used as a commenting system and for other functions, such as distributing shares, likes, bookmarks, RSVPs, and more across websites.

By using a third party service, such as <https://brid.gy>, social media activity can be "backfed" to the authors' websites.

The authors' CMS apps would send Webmentions to Brid.gy to syndicate their posts to Twitter, Facebook, Instagram, etc., and Brid.gy would send any social media activity back to the authors' websites as Webmentions (backfeeding). The authors' websites would send and receive Webmentions. Then depending upon how their personal websites are configured, the authors can display the social media activity as comments under their respective posts.

It looks like the authors are using social media directly, but they aren't. It looks like others posted comments directly on the authors' websites, but they didn't.

Another Webmention example involves users creating RSVP-type posts on their websites, and then their publishing apps send the RSPV Webmentions to the websites that announced the events, provided that the sites accepts Webmentions.

Some websites accept Webmentions by displaying HTML text input fields, and authors can manually copy the URLs to their posts and paste them into the text input fields.

A Webmention post is considered the source URL. This post must contain the URL of the post that the author is responding to, which is called the target URL.

A protocol describes how Webmentions are sent and received, but website owners who receive Webmentions can display them however they desire.

More info about the Webmention can be found at: 

* <https://indieweb.org/webmention>
* <https://webmention.net>

From the IndieWeb:

> Webmention is a web standard for mentions and conversations across the web, a powerful building block that is used for a growing federated network of comments, likes, reposts, and other rich interactions across the decentralized social web.

To reduce abuse by spammers and trolls, the IndieWeb community recommends implementing the Vouch protocol with Webmention.

* <http://indieweb.org/Vouch> 

> The Vouch protocol is an anti-spam extension to Webmention

Warbler does not use Vouch.

Some personal website authors moderate the Webmentions that they have received before allowing them to be displayed.

The Webmention spec can be found at <https://www.w3.org/TR/webmention>, which  suggests:

> The Webmention endpoint will validate and process the request, and return an HTTP status code [RFC7231]. Most often, 202 Accepted or 201 Created will be returned, indicating that **the request is queued and being processed asynchronously** to prevent DoS (Denial of Service) attacks. 

Asynchronously processing a received Webmention is a suggestion. Warbler does not do this either.

Warbler implements throttling for the entire website and for each author's domain name.

The test website is found at <http://warbler.soupmode.com>.

A post from any domain name is accepted at most once every 60 seconds.

A post from any specific author's domain name is accepted at most once every five minutes.

Those settings exist in the Warbler YAML file.

Warbler offers a Webmention endpoint. Some web publishing apps can programmatically send Webmentions. The Warbler Webmention endpoint is listed within each web page on the Warbler website. 

A user can also use the cUrl command-line tool to send Webmentions to Warbler's endpoint.

Other barriers could be added to reduce DoS attempts and spamming, such as removing the endpoint and requiring all Webmentions to be posted manually by copying and pasting the URLs into text input fields at the Warbler site. Of course, this action can be scripted.

An additional barrier would be to require each user to log into the Warbler site by using IndieAuth before submitting a Webmention. More info about IndieAuth can be found at:

* <http://indieweb.org/indieauth>

IndieAuth requires an additional layer of "work" for the users who want to post to a Warbler message board. They must be logged into another service, such as GitHub, Twitter, Facebook, etc., and their personal websites must point to their social media accounts, and their social media accounts must point to their personal websites.

Nearly everything can be scripted. None of these ideas completely prevent determined trolls and spammers, but innovating more barriers can help. If the goal is to create a community, then real community users won't mind the barriers. More users and more comments are not always better.

In my opinion, a Webmention-based message board or commenting system can lead to better quality discussions. 

If a publisher simply no longer wants to accept contributions of any type from other users, then that's a good reason to disable comments.

But if the reason for disabling comments is because the comment sections have become too toxic and/or because most of the discussions occur on social media, then those are not good reasons to disable comments.

Facebook's real-name policy has not made comments more civil. Toxic comments occur frequently at Twitter, and Twitter's 140-character limitation makes it nearly useless as a commenting system. Tweetstorms and posting blobs of text as image attachments are horrible solutions for circumventing Twitter's character limit.

The idea of comments or user-contributed content is not the problem. It seems to me that many publishers blame the concept of comments as a reason why discussions turn toxic. 

In my opinion, the failure or the blame belongs to the publishers for not innovating ways to create a worthwhile community. If comment sections are terrible, then 100 percent of the blame belongs to the publishers.

If the goal is only to increase page views, then publishers will use few to no barriers to entry for commenting, and this could lead to messy discussions. 

From my experience at managing the small message board <http://toledotalk.com>, since January 2003, the more barriers implemented, the better the discussions, which leads to a more respectful community.

But Toledo Talk is a silo. The IndieWeb community can be distilled to this [main idea](http://indieweb.org/indieweb):

> The IndieWeb is about owning your domain, using it as your primary identity to publish on your own site (optionally syndicate elsewhere), and owning your data.

The IndieWeb community is not trying to get people to stop using social media. The IndieWeb community is encouraging users to buy their own domain names, manage their own websites, and store as much of their social media content on their own domain. Some content may not be worthy of public consumption, but public posts to Medium, Svbtle, Instragram,  and Twitter could be article, photo, and note-type of posts on the authors' own personal websites.

I created Warbler in July-August 2017. I have always liked online communities, such as Slashdot, MetaFilter, evolt, Fark, kuro5hin, and Hacker News.

The IndieWeb community formed in 2010. They are taking a long, slow approach to establishing the tech and making it easier to use for non-tech people. But users do not need to implement the advanced concepts of the IndieWeb to be considered a part of the IndieWeb. 

IndieWeb functionality like IndieAuth, Webmentions, Microformats, WebSub, and Micropub are nice to have, but none of those things are required. Users support the IndieWeb by managing websites on their own domain names, and posting all or most of their online content on their own websites.

I first learned of the IndieWeb in the summer of 2013. In the fall of 2013, I add the ability to receive Webmentions to one of my web publishing apps. I also added support for some Microformats.

Across May-June 2017, I enabled the following in my web-based static site generator called Wren:

* sending and receiving Webmentions
* logging in with IndieAuth
* supporting Micropub on the server
* supporting more Microformats

Hopefully, my Microformat support is also more correct.

By providing a Micropub endpoint, I can use Micropub-supported clients, created by others to create web posts on my Wren-backed websites. Example web-based Micropub editors included <https://micropublish.net>
 and <https://quill.p3k.io>, the Chrome web browser extension called Omnibear, and feed reader <http://woodwind.xyz>.

This post inspired me to support more IndieWeb concepts.

<http://altplatform.org/2017/06/09/feed-reader-revolution>

Webmentions provide a way to post comments from one website to another. But I wondered if an online community could be created around a message board-like website that focused only on Webmentions. 

Users would create content on their own websites or web presences. Preferably the former with their own domain names. Only a portion of the posts would be displayed in the Warbler app. Readers would have to click the links to the authors' websites to read the entire posts, unless it was a short post.

This might lead to the discovery of other personal publishers, and it might encourage more readers to launch their own websites.
