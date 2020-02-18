// IM360NotificationFactory.aidl
package com.splashtop.m360.service;

import android.app.Notification;

interface IM360NotificationFactory {

    /**
     * Called on service need running on foreground.
     */
    Notification create(int notificationId);
}
