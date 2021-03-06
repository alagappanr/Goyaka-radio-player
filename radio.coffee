window.GoyakaPlayer = GoyakaPlayer = {}
window.GoyakaPlayer.currentPlayId = 0;
window.GoyakaPlayer.songs = []
GoyakaPlayer.STOPPED = 0

window.GoyakaPlayer.fetch_feeds =->
    feeds = jQuery('.fbGroupsStream li.uiUnifiedStory')
    for feed in feeds
        link = jQuery(feed).find('.uiAttachmentTitle a')
        if link.length > 0
            actor_image = jQuery(feed).find('.actorPhoto img').attr('src')
            actor_name  = jQuery(feed).find('.actorName a').html()
            message     = jQuery(feed).find('.messageBody').html()
            song = $(link[0])
            song_item = 
                actor_image: actor_image
                actor_name: actor_name
                message: message
                song: song.find('span').html()
                url: song.attr('href')
                
            window.GoyakaPlayer.songs.push(song_item)
    

get_youtube_id = (url)->
    regex_pattern = /.*v=([^&.]*)/
    matches = regex_pattern.exec(url)
    if matches.length > 1
        return matches[1]
    else
        return false
        
window.GoyakaPlayer.add_player_listeners =->
    if is_player_loaded()
        window.setInterval(pollPlayerState, 5000)
    else
        window.setTimeout(window.GoyakaPlayer.add_player_listeners, 10000)

playNext =->
    console.log('Playing next song')
    window.GoyakaPlayer.currentPlayId = window.GoyakaPlayer.currentPlayId + 1
    playSong(window.GoyakaPlayer.currentPlayId)

    
pollPlayerState =->
    player = document.getElementById('goyakaplayer')
    player_state = player.getPlayerState()
    if player_state == GoyakaPlayer.STOPPED
        playNext()
    
window.GoyakaPlayer.add_player_box =->
    player_wrap = jQuery('<div style="padding:2px; border:1px solid #333; border-radius:3px;position:fixed;bottom:-7px;left:20%;background-color:#fff;zoom:2;z-index:99999999;"><div id="goyakatube"></div></div>')    
    jQuery('body').append(player_wrap)
    
    params = { allowScriptAccess: "always" };
    atts = { id: "goyakaplayer" };
    first_youtube_id = get_youtube_id(window.GoyakaPlayer.songs[0]['url'])
    
    swfobject.embedSWF("https://www.youtube.com/v/" + first_youtube_id + "?enablejsapi=1&playerapiid=ytplayer&version=3",
                       "goyakatube", "150", "80", "8", null, null, params, atts);
                       
    window.GoyakaPlayer.add_player_listeners()
    

is_player_loaded =->
    if document.getElementById('goyakaplayer')
        true
    else
        false
    
notifySong = (id)->
    song = window.GoyakaPlayer.songs[id]
    text = song['actor_name'] + ' ' + song['message']
    chrome.extension.sendRequest
        action: 'notification',
        image: song['actor_image'],
        title: song['actor_name'], 
        message: song['message']
    
playSong =(id)->
    player = document.getElementById('goyakaplayer')
    youtube_id = get_youtube_id(window.GoyakaPlayer.songs[id]['url'])
    player.cueVideoById(youtube_id)
    player.playVideo()
    notifySong(id)
    
window.GoyakaPlayer.play =->
    if is_player_loaded()
        playSong(0)
    else
        window.setTimeout(window.GoyakaPlayer.play, 5000)