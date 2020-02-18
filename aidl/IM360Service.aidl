
package com.splashtop.m360.service;

import com.splashtop.m360.service.IM360Callback;
import com.splashtop.m360.service.IM360NotificationFactory;

interface IM360Service {

    /**
     * Register a callback to receive server state change, once register, will got current state notify immediately
     *
     * @param cb            @see IM360Callback
     */
    void registerCallback(IM360Callback cb);

    /**
     * Remove the callback, will not affect the service running
     *
     * @param cb            @see IM360Callback
     */
    void unregisterCallback(IM360Callback cb);

    /**
     * Set option for server, options will not be persist, each time create the server
     * All the options need set again, or else the server will use default value
     *
     * @param key               "allowAirplayProbe" : int value
     *                          Allow TX1 probe from port 47000, default 1
     *
     *                          "allowPlainMessage" : int value
     *                          Allow WinTX1 connect to port 7200, default 1
     *
     *                          "verifyCert" : int value
     *                          Verify certificate for port 7201, default 0, will trust all clients
     *                          If set to true, new message client connect will trigger onChannelVerifyCertificate()
     *
     *                          "extraMirrorJitter" : int value, in ms(1/1000 second)
     *                          On bad network environment, we can allow larger jitter buffer when playing airplay mirror, default 0
     *                          0: Streaming mode, use TX PTS to play back, no extra jitter
     *                          Other positive value: Buffer mode, allow extra PTS adjustment to align audio and video
     *
     *                          "messageServerCert" : byte array value
     *                          X509 certificate in PEM format
     *
     *                          "messageServerKey" : byte array value
     *                          RSA key in PEM format
     *
     *                          "messageServerKeyPhrase" : String value
     *                          Password for decrypting the key
     */
    void serverOptionInt(String key, int value);
    void serverOptionString(String key, String value);
    void serverOptionBuffer(String key, in byte[] value);

    /**
     * Start the server, listen on socket and register bonjour service
     *
     * @param addressList   The address list for server binding
     *                      Empty or null will bind on all/any interface
     */
    void serverStart(in List<String> addressList);

    /**
     * Stop the server, this may also disconnect all the connections
     */
    void serverStop();

    /**
     * Force disconnect the specified device airplay connection
     *
     * @param deviceId      Device identifier, @see IM360Callback::onDeviceConnected()
     */
    void deviceDisconnect(String deviceId);

    /**
     * Set playback volume for airplay sessions
     *
     * Final volume for audio dirver will be SourceVolume * PlaybackVolume
     * @See onAudioVolume()
     *
     * @param deviceId      Device identifier, @see IM360Callback::onDeviceConnected()
     * @param volume        Playback loudness volume in range [0, 1]
     *   0.0f (0%)
     *   0.8f (80%)
     *   1.0f (100%)
     */
    void deviceVolume(String deviceId, float volume);

    /**
     * Stop the message channel
     *
     * @param channelId     Channel identifier, @see IM360Callback::onChannelConnected()
     */
    void channelDisconnect(long channelId);

    /**
     * Send message to message channel, the message will pass through sender's SDK transparently
     *
     * @param channelId     Channel identifier, @see IM360Callback::onChannelConnected()
     * @param message       Message content, any type you want, XML JSON BSON or etc
      *                     Make sure sender UI can parse it correctly
     */
    void sendChannelMessage(long channelId, in byte[] message);

    /**
     * Send command to message channel, the command will be handle by sender internally
     *
     * @param channelId     Channel identifier, @see IM360Callback::onChannelConnected()
     * @param commandId     Command id
     *   0: Start
     *   1: Stop
     *   2: Pause
     *   3: Resume
     */
    void sendChannelCommand(long channelId, int commandId);

    /**
     * Attach a surface to session
     *
     * @param sessionId     Session identifier, @see IM360Callback::onVideoStart()
     * @param surface       Surface for current session
     */
    void attachSurface(int sessionId, in Surface surface);

    /**
     * Detach a surface from session
     *
     * @param sessionId     Session identifier, @see IM360Callback::onVideoStart()
     * @param surface       Surface for current session
     */
    void detachSurface(int sessionId, in Surface surface);

    /**
     * Bonjour service ON
     *
     * @param isEnable      TRUE: Enable register bonjour service when start server
     *                      FALSE: Disable register bonjour service, notify bonjour info from IM360Callback instead
     *
     *                      Default is enabled
     */
    void setBonjour(boolean isEnable);

    /**
     * Turn WebRTC supports ON or OFF
     * WebRTC is for Chrome sender connect and mirror
     * Setup WebRTC session need provide a signal server on port 7300, currently use plain text protocol
     * If use TLS to secure the port, Chrome will force verify the certificate, RX need deploy with a valid domain name and issue a valid certificate for the domain by a Chrome trusted CA
     *
     * @param isEnable      TRUE: Enable WebRTC supports when start server, if server already started with rtc disabled, need re-start the server manually to take effect
     *                      FALSE: Disable WebRTC supports, disable binding on port 7300, if server already start with rtc enable, can stop listening the port immediately
     *
     *                      Default is enabled
     */
    void setWebRtc(boolean isEnable);

    /**
     * Set product id argument, will be pass to TX device for identify RX device
     *
     * @param productId     Product identifier, can be set to any value, fill as bonjour and airplay probe attributes
     * @param productName   Product name, will in bonjour and airplay probe attributes
     */
    void setProductInfo(int productId, String productName);

    /**
     * Change the device name showing on bonjour discovery
     * If server already start, this may re-register bonjour service
     *
     * @param name          Device name
     */
    void setServerName(String name);

    /**
     * Get the current device name
     *
     * @return              Current device name
     */
    String getServerName();

    /**
     * Get service version
     *
     * @return              Current service version, e.g. 0.9.9.0
     */
    String getServerVersion();

    /**
     * Change the password when device connected, set to NULL if do not need check password
     * If server already start, this may re-register bonjour service
     *
     * @param password      Password
     */
    void setServerPassword(String password);

    /**
     * Get the current password
     *
     * @return              Current password used, NULL for no password
     */
    String getServerPassword();

    /**
     * Set default accepted max resolution, default 0 (720P)
     *
     * @param resolution    Resolution index
     *   0: 720P
     *   1: 1080P
     *   2: 2160P
     */
    void setMaxResolution(int resolution);

    /**
     * Get current accepted max resolution
     *
     * @return              Resolution index, @see setMaxResolution()
     */
    int getMaxResolution();

    /**
     * Enable or disable the debug mode, default FALSE
     *
     * @param isDebug       TRUE: Will print debug log into both logcat and /mnt/sdcard/m360.rx.log
     *                      FALSE: Will print only info level log into logcat with tag ST-M360
     */
    void setDebugMode(boolean isDebug);

    /**
     * Force run in compatible mode, default FALSE
     *
     * @param isEnable      TRUE: Force fallback to software decoder
     *                      FALSE: Try enable hardware decoder
     */
    void setCompatibleMode(boolean isEnable);

    /**
    * Set notification factory, the notifaction needed on service start on foreground
    */
    void setNotificationFactory(IM360NotificationFactory factory);
}
