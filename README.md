# Warbler README

Warbler is a message board where all thread starter posts and comments are Webmentions.

The test website is found at <http://warbler.soupmode.com>.

Here's a [shorter description](http://sawv.org/2017/08/17/warbler-description.html) about Warbler and Webmention.

For the above test website, I disabled the check that searches the target content for the source URL. I wanted to test the code that parses HTML pages, database storage and retrieval, and web display.

The [Warbler Testing](http://sawv.org/2017/07/24/warbler-testing.html) page contains a list of URLs that I tested, and the page shows how the content should be displayed after parsing.

In June 2017, I [jotted down](http://sawv.org/2017/06/25/webmentionbased-message-board-idea.html) my initial thoughts for a Webmention-based message board.

This page titled [Warbler - Webmention-based Message Board](http://sawv.org/2017/07/11/warbler-webmentionbased-message-board.html) contains ideas and development notes from the two or three weeks of off-and-on programming that I did in July-August 2017 to get Warbler running. 

Most of that time was spent creating and testing the code to parse HTML pages that would produce worthwhile display within Warbler. I should have known that parsing HTML pages would be tricky and a bit frustrating, since authors can format their pages in nearly anyway they want. Authors are not required to use semantic HTML tag markup.

A Webmention is a cross-site communication idea, espoused by the IndieWeb community. It may remind some of the trackback and pingback functionality that many blog sites offered back in the aught years.

Webmentions can be used as a commenting system and for other functions, such as distributing shares, likes, bookmarks, RSVPs, and more across websites.

By using a third party service, such as <https://brid.gy>, social media activity can be "backfed" to the authors' websites.

The authors' CMS apps would send Webmentions to Brid.gy to syndicate their posts to Twitter, Facebook, Instagram, etc., and Brid.gy would send any social media activity back to the authors' websites as Webmentions (backfeeding). The authors' websites would send and receive Webmentions. Then depending upon how their personal websites are configured, the authors can display the social media activity as comments under their respective posts.

It looks like the authors are using social media directly, but they aren't. It looks like others posted comments directly on the authors' websites, but they didn't.

[Example](https://nicolas-hoizey.com/2017/07/so-long-disqus-hello-webmentions.html#webmentions) web post where the "comments" "posted" at this personal website rely on the Webmention.

Another Webmention example involves users creating RSVP-type posts on their websites, and then their publishing apps send the RSPV Webmentions to the websites that announced the events, provided that the sites accepts Webmentions.

Some websites accept Webmentions by displaying HTML text input fields, and authors can manually copy the URLs to their posts and paste them into the text input fields.

A Webmention post is considered the **source URL**. This post must contain the URL of the post that the author is responding to, which is called the **target URL**.

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

The initial version of Warbler was built with:

* Ubuntu Linux
* Nginx
* FastCGI
* Perl
* HTML::Template
* CouchDB
* Memcached

The app is small. Parsing the HTML for the Webmentions was the tricky part. But I would like to create additional versions of Warbler in one or more other programming languages.

If I implement a search function, I'll use Elasticsearch. Search, however, would be restricted to searching the excerpts stored by Warbler in the CouchDB database.


### August 2017 commenting thoughts

Aug 31, 2017 - cjr.org - [From civil to cesspool: Local news battles offensive comments](https://www.cjr.org/united_states_project/comments-trolling-post-and-courier.php)

> LAST WEEK, AS THE CHARLESTON POST & COURIER covered a hostage standoff and shooting at a local restaurant, editor Mitch Pugh announced his paper would shut down comments on the developing story.

> Pugh has advised his Twitter followers for years to avoid the comments sections on stories and social media sites. 

Strange. A newspaper editor used social media to tell other social media people not to read and post to social media.

Pugh's August 2015 [tweet](https://mobile.twitter.com/SCMitchP/status/633789381736820736)

> Don't read the Facebook comments. Don't read the Facebook comments. Don't read the Facebook comments. Don't read the Facebook comments.

As if Twitter comments or discussions are better. It's hard to comprehend this. Use Twitter, which can easily be the cesspool of the web, to tell people not to read Facebook comments. 

But Facebook and Twitter can be useful too, as can be message boards, comment sections on blog posts, and comment sections for newspaper articles. I don't think that a singular viewpoint can be applied widely for all services.

Back to the cjr.org article.

> But responses to coverage of the shooting in Charleston—a scene that gripped a city familiar with gun violence and the national news—compelled Pugh to shut down comments on a story at the P&C for the first time he can recall.

> The Post & Courier followed its breaking news coverage with [a story about the comments](http://www.postandcourier.com/news/a-deadly-shooting-at-a-charleston-restaurant-unleashes-a-torrent/article_5cd0c928-890a-11e7-b58f-e3b011d039d2.html) its work attracted—“a torrent of racist, conspiratorial, politically-charged and outright bizarre comments.” For that story, Pugh said most of the comments “were coming from outside of our market.” The P&C also noted an uptick in comments after its coverage caught a link from The Drudge Report.

> The incident in Charleston reignited a debate about whether local news outlets should keep online comments—and just how to keep such comments civil. Countless newsrooms rely on comments sections and social media to foster community engagement and **drive traffic to their sites,** but those platforms are too frequently hosts to hate, bigotry, threats and damaging content. Many of those newsrooms lack the resources required to clean up comments or scrub offensive material from such platforms. “A lot of editors in the country are struggling with how to handle this,” Pugh says.

If web traffic is a goal for commenting systems, then that media site is already on a road to failure, regarding user-contributed content. It's only a matter of time before the newspaper removes comments from its articles.

cjr.org story:

> However, some local newsrooms are experimenting with new technology to try and disinfect the cesspools that can swirl in the spaces below online stories.

Excerpts from the Aug 24, 2017 Post & Courier [article](http://www.postandcourier.com/news/a-deadly-shooting-at-a-charleston-restaurant-unleashes-a-torrent/article_5cd0c928-890a-11e7-b58f-e3b011d039d2.html) about comments:

> "Don't read the comments" is the tried and truest rule of the internet as online discourse inevitably devolves into toxic cesspools of human expression. Jessie Daniels, a sociology professor at City University of New York's Hunter College, and an expert on internet racism, blames this phenomenon on the uniquely "depersonalized and intimate" *nature of the online comments section.*

Nope. Wrong. Anil Dash explained the answer in his 2011 blog post titled [If You Website's Full OF Assholes, It's YOUR Fault](http://anildash.com/2011/07/if-your-websites-full-of-assholes-its-your-fault.html)

100 percent of the blame belongs to the Post & Courier, including its editor Mitch Pugh and the author of the above P&C article. Trolls, drive-by flamers, and general a-holes are acting as expected. It's who they are. They are predictable. 

It's up to the publishers to erect barriers to irritate and discourage the flamers. If most of the comments for the one P&C story were from the outside, how easy was it for visitors to post comments on the P&C website? 

A simple barrier is to require would-be commenter to provide a valid email address when creating an account. An activation link gets sent to the user who cannot post a comment until the user clicks the link in the email to activate the account.

But wait, there's more. Add another barrier where this new commenter cannot post a comment until the user's account is at least 24-hours-old. What's wrong with that? Nothing. In fact, increase the time frame to 48 hours or 72 hours. 

Forcing a new user to wait one to three days or more won't harm anything because if the goal is truly to create a community, then a community member won't mind waiting a couple days to post a comment. If flamers don't want to wait, then they will probably never post, which means the barriers worked, prevening toxic comments from getting posted.

Barriers, barriers, barriers.

Publishers do not need complex technology to manage comments systems. They need to be creative with inventing their barriers. 

It appears that the P&C permitted Facebook comments. Why? How long ago did the P&C give up trying to implement their own comment system and buy into the myth that Facebook comments led to more civil discussions?

In my opinion, a media org implementing Facebook comments at the bottom of news articles is another eventual failure, regarding user-contributed content. Is using Facebook comments meant to create a community or to create traffic?

If P&C permitted Facebook comments, it seems to me that their system did not restrict commenting only to paying customers. If anyone with a Facebook account could comment on P&C stories, then that's P&C's fault. That's P&C's failure.

When viewing a P&C article, I cannot determine how to post comments. Maybe they disabled comments for all articles now.

More from their article about comments:

> But on Facebook, the devastating news unleashed a torrent of racist, conspiratorial, politically-charged and outright bizarre comments.

I don't understand "on Facebook". Does this mean Facebook comments that get embedded at the bottom of P&C articles, or does the writer mean at facebook.com?

More from the P&C story about comments:

> There's another reason, too, why you may be noticing more overtly racist comments online. Daniels blames the rise of the so-called "alt-right" — the re-branded face of white supremacy — that has successfully infiltrated mainstream politics and media with help from social media and white supremacist websites like Stormfront.

When publishers, journalists, and researchers fail to see the problem in plain sight, then we'll see more idiotic reasons like above. Several years ago, the Toledo Blade switched from its own commenting system to Facebook comments. 

I started my message board toledotalk.com in 2003, but it took me until 2010 until I finally found a set of barriers that discouraged the spammers, trolls, and drive-by flamers. The drive-by flamers like to create an account and post one comment or comment only in one current thread, and that's it. Site owners should discourage all of this behavior. One-thread posters and one-day wonders do not build a community.

Again, Dash's [article](http://anildash.com/2011/07/if-your-websites-full-of-assholes-its-your-fault.html is from 2011, but it applied to 2001 too. None of the commenting problems that exist on newspaper websites in 2017 have anything to do with politics in 2017. The problem has existed for 20 years, and it's enabled by site owners.

Either disable comments altogether or innovate barriers to encourage quality over quantity. Media orgs like to complain, which solves nothing, especially when they are to blame, but they don't recognize this fact. 

If media orgs want to try complex technology sanitize comment sections, that's fine, but I don't think that this topic needs over-thinking.

Years ago, MetaFilter implemented a barrier where new users had to pay a one-time, lifetime fee of either $1 or $5. Why don't media orgs do that if they are going to open their comment sections to everyone? 

In my opinion, newspaper orgs should restrict their comment sections to subscribers, and the comments should be private. In other words, the comment sections are hidden from public view. Only logged-in subscribers can read and post comments. Barriers.

No barriers or barriers that are super easy to circumvent are signs to me that the media org only wants comment sections to generate web traffic, and the org is not serious about nurturing a community with thoughtful discussions on the topics covered by the newspaper.

When publishers make it easy for trolls and flamers to destroy a comments section, then I blame the publishers and not the trolls. 

Excerpts from Dash's 2011 post that editors like Pugh need to read:

> If you run a website, you need to follow these steps. if you don't, you're making the web, and the world, a worse place. And it's your fault. Put another way, take some goddamn responsibility for what you unleash on the world.

> How many times have you seen a website say "We're not responsible for the content of our comments."? I know that when you webmasters put that up on your sites, you're trying to address your legal obligation. Well, let me tell you about your moral obligation: Hell yes, you are responsible. You absolutely are. When people are saying ruinously cruel things about each other, and you're the person who made it possible, it's 100% your fault. If you aren't willing to be a grown-up about that, then that's okay, but you're not ready to have a web business. Businesses that run cruise ships have to buy life preservers. Companies that sell alcohol have to keep it away from kids. And people who make communities on the web have to moderate them.

Dash makes multiple suggestions, but he failed to discuss barriers to entry. 

I bought the toledotalk.com domain name in September 2001. In late 2002, I started building my code for toledotalk.com. For about a year, I read and studied other community websites. I read the book [Design for Community: The Art of Connecting Real People in Virtual Places](https://www.amazon.com/Design-Community-Derek-Powazek/dp/0735710759/kvetch) by [Derek Powazek](http://powazek.com/about) who wrote about barriers to entry.

No rule states that website owners must make it easy for users to post their comments.


