package net.m3mobile.app.scanemul;

interface IScannerCallback {
    oneway void onDecoding(String code, String type, in byte[] byteCode);
}
