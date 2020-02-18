
package com.splashtop.m360.service;

/**
 * Register for watching server state changed
 */
interface IM360Callback {

    /**
     * Called when server status changed, or notify current status when callback registered
     *
     * @param newState      New state changed to
     *
     *   0: IDLE        App inited, identical with STOPPED, for distinguish server switch from STOPPING to STOPPED
     *   1: STARTING    Start command received, will listen on socket and register bonjour service
     *   2: STARTED     Socket listened, bonjour registering in the background, M360 server will appear on iPad/iPhone's airplay list soon
     *   3: STOPPING    Stop command received, will shutdown all the process/threads and stop listening on socket
     *   4: STOPPED     Socket not listening, bonjour service unregisted
     *
     *  DeviceBooted -> IDLE -> start() -> STARTING -----> STARTED
     *                                        ↑               ↓
     *                                      start()         stop()
     *                                        ↑               ↓
     *                                     STOPPED <------ STOPPING
     *
     * @param reason    Reason why state changed, NONE or errors
     *
     *   0:   NONE                  State change for success
     *   1:   ERR_CODEC_EXCEPTION   Happen in state STARTED, when a session begin but got some MediaCodec exception, we will trigger the state change again, with the error code, onServerState(STARTED, ERR_CODEC);
     *   2:   ERR_CODEC_TIMEOUT     Happen in state STARTED, when a session call for MediaCodec functions and hang in that function call for 10 seconds, the watchdog may trigger this error
      *  -99: EADDRNOTAVAIL         Start server with specified address, but failed to bind the address
     */
    void onServerState(int newState, int reason);

    /**
     * When mirror assist registed and info updated
     *
     * @param mirrorId      Mirror id for displaying on UI, usually 9-digit number
     *                      M360 TX can input this id to connect with RX manually
     *
     * @param mirrorDesc    Mirror info for displaying as QRCode on UI
     *                      M360 TX can scan the QRCode to connect with RX directly
     */
    void onAssistInfo(String mirrorId, String mirrorDesc);

    /**
     * When bonjour service was disable, we can send the bonjour info out for app layer to register it manually
     *
     * @param airplayInfo   Json format AirPlay service info
     * @param raopInfo      Json format RAOP service info
     *
     * Info attributes
     * {
     *   "type": "_airplay._tcp.local." // service type
     *   "name": "OMAP5 panda"          // service name
     *   "host": "192.168.120.180"      // service address
     *   "port": "47000"                // service port
     *   "attrs": {                     // text record map
     *     "product": "1"
     *     "product_name": ""
     *     "version": "1.3.2.11"
     *     ...
     *   }
     * }
     *
     * Full version of JSON string
     * {"type":"_airplay._tcp.local.","name":"OMAP5","host":"\/192.168.120.180","port":47000,"attrs":{"deviceid":"80:0A:80:58:31:6F","features":"0x5A7FFFF7,0x1E","flags":"0x4","model":"AppleTV3,2","pw":"false","pk":"4505EE773711AE368D8D64A8D6E4B7263B993C437DDD848172BDCC3A1E805AD0","srcvers":"220.00","vv":"2","mport":"7200","msport":"7201","version":"1.3.2.11","product":"1","product_name":"ProductName"}}
     * {"type":"_raop._tcp.local.","name":"800A8058316F@OMAP5","host":"\/192.168.120.180","port":47000,"attrs":{"am":"AppleTV3,2","ch":"2","cn":"1,3","da":"true","et":"0,3,5","ft":"0x5A7FFFF7,0x1E","md":"0,1,2","pk":"4505EE773711AE368D8D64A8D6E4B7263B993C437DDD848172BDCC3A1E805AD0","pw":"false","sf":"0x4","tp":"UDP","vn":"65537","vs":"220.00","vv":"2"}}
     */
    void onBonjourInfo(String airplayInfo, String raopInfo);


    /**
     * When message channel connected
     *
     * @param channelId     Message channel identifier
     * @param channelInfo   Message channel info in JSON string, include device id, device name and address in a list
     *
     * Sample of JSON string
     *   {"channel_id":-1639211584,"device_id":"7303bde6b0ef","device_name":"MINOTELTE-0EE08B","address":["10.254.46.21"]}
     *
     * Device id will be fake value 020000000000 from iOS and MacOS
     */
    void onChannelConnected(long channelId, String channelInfo);

    /**
     * When message channel received transparent message
     *
     * @param channelId     Message channel identifier
     * @param message       Message content
     */
    void onChannelMessage(long channelId, in byte[] message);

    /**
     * When message channel get update IP list from remote client
     *
     * @param addrJson      Device address list, as JSON array
     *
     * Sample of the JSON array
     *   ["fe80::c4f1:c4ff:feba:710b","fe80::3680:b3ff:fee9:3394","10.254.46.21"]
     */
    void onChannelAddress(long channelId, String addrJson);

    /**
     * When message channel disconnected
     *
     * @param channelId     Message channel identifier
     */
    void onChannelDisconnected(long channelId);

    /**
     * When server configure to verify client certificate
     * and a new client was connected
     *
     * @param cert          Channel client certificate
     *
     * @return              Trust the certificate and allow the client continue
     *
     * @see serverOption()
     */
    boolean onChannelVerifyCertificate(in byte[] cert);


    /**
     * When client device connected
     *
     * @param deviceId      Device identifier, used to group airplay sessions
     * @param deviceInfo    Device info in JSON string, include device name, device model, and address in a list, actually only one address in logical
     *
     * Sample of JSON string
     *   {"device_id":"3c15c2ea25e2","device_name":"MBP－LiuJun","model_name":"MacBookPro11,1","user_agent":"AirPlay\/215.18","address":["10.254.44.207"]}
     *
     * ModelName can reference to 'Hardware strings' on https://en.wikipedia.org/wiki/List_of_iOS_devices
     * Or 'Model identifier' or 'Machine Model' on https://en.wikipedia.org/wiki/MacBook, https://en.wikipedia.org/wiki/MacBook_Pro, https://en.wikipedia.org/wiki/MacBook_Air
     * e.g.
     *   "iPhone7,1" for iPhone6Plus
     *   "iPad5,3" and "iPad5,4" for iPadAir2
     *   "MacBookPro11,1" for MacBook Pro (Retina, 13-inch, Mid 2014)
     */
    void onDeviceConnected(String deviceId, String deviceInfo);

    /**
     * When airplay device disconnected
     *
     * @param deviceId      Airplay device identifier
     */
    void onDeviceDisconnected(String deviceId);

    /**
     * When remote device appear
     *
     * @param address      Remote device address
     */
    void onDeviceAppear(String address);

    /**
     * Called when video session started
     *
     * @param sessionId     Session identifier
     * @param deviceId      Device identifier
     * @param type          Video type
     *                      1: Mirror
     *                      2: Video
     *                      3: WebRTC
     */
    void onVideoStart(int sessionId, String deviceId, int type);

    /**
     * Called when video session stopped
     *
     * @param sessionId     Session identifier
     */
    void onVideoStop(int sessionId);

    /**
     * Called when video session paused, can show/hide a paused icon for the status
     *
     * @param sessionId     Session identifier
     * @param isPaused      Paused status
     */
    void onVideoPause(int sessionId, boolean isPaused);

    /**
     * Called when video session get size info
     *
     * @param sessionId     Session identifier
     * @param width         Video width
     * @param height        Video height
     */
    void onVideoResize(int sessionId, int width, int height);

    /**
     * Called when video session get rotation info
     *
     * @param sessionId     Session identifier
     * @param rotation      Video rotation in degree { 0, 90, 180, 270 }
     */
    void onVideoRotate(int sessionId, int rotation);

    /**
     * Called when video session in loading, can show/hide a waiting animate for the status
     *
     * @param sessionId     Session identifier
     */
    void onVideoLoading(int sessionId, boolean isLoading);

    /**
     * Called when a device try to play a unsupported video URL
     *
     * @param deviceId     Device identifier
     */
    void onVideoDrm(String deviceId);

    /**
     * Called when video render changed.
     *
     * @param sessionId     Session identifier
     * @param renderType    Current render, for SDK usage, no different between the type
     *                      Both render type request a surface to draw
     *                      Just make sure re-create the surface and attach again when render changed
     *                      1: S/W render
     *                      2: H/W render
     */
    void onVideoRender(int sessionId, int renderType);

    /**
     * Called when video session change volume, we call it SourceVolume
     *
     * We will apply SourceVolume * PlaybackVolume for audio driver
     * Notify the volume change just for showing on UI to inform user the remote side wants to update it
     * @See deviceVolume()
     *
     * @param sessionId     Session identifier
     * @param volume        SourceVolume loudness value in range [0, 1]
     *   0.0f (0%)
     *   0.8f (80%)
     *   1.0f (100%)
     */
    void onVideoVolume(int sessionId, float volume);

    /**
     * Called when audio session started
     *
     * @param sessionId     Session identifier
     * @param deviceId      Device identifier
     */
    void onAudioStart(int sessionId, String deviceId);

    /**
     * Called when audio session stopped
     *
     * @param sessionId     Session identifier
     */
    void onAudioStop(int sessionId);

    /**
     * Called when session got audio cover
     *
     * @param sessionId     Session identifier
     * @param coverArt      Audio cover image
     */
    void onAudioCover(int sessionId, in Bitmap coverArt);

    /**
     * Called when session got audio meta string
     *
     * @param sessionId     Session identifier
     *
     * @param type          Meta data type
     *   1: ARTIST  Artist name
     *   2: NAME    Title name
     *   3: ALBUM   Album name
     *
     * @param value         Meta string value
     */
    void onAudioMeta(int sessionId, int type, String value);

    /**
     * Called when the audio session changes volume, we call it SourceVolume
     *
     * We will apply SourceVolume * PlaybackVolume for audio driver
     * Notify the volume change just for showing on UI to inform user the remote side wants to update it
     * @See deviceVolume()
     *
     * @param sessionId     Session identifier
     * @param volume        SourceVolume loudness value in range [0, 1]
     *   0.0f (0%)
     *   0.8f (80%)
     *   1.0f (100%)
     */
    void onAudioVolume(int sessionId, float volume);
}
