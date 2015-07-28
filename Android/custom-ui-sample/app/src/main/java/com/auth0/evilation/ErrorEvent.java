package com.auth0.evilation;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;

public class ErrorEvent {

    private Dialog dialog;
    private int title;
    private int message;
    private Throwable throwable;

    public ErrorEvent(Dialog dialog) {
        this.dialog = dialog;
    }

    public ErrorEvent(int title, int message, Throwable throwable) {
        this.title = title;
        this.message = message;
        this.throwable = throwable;
    }

    public Dialog showDialog(Context context) {
        if (dialog != null) {
            dialog.show();
            return dialog;
        }
        throwable.printStackTrace();
        return new AlertDialog.Builder(context)
                .setCancelable(true)
                .setTitle(title)
                .setMessage(message)
                .setNeutralButton("Ok", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        dialogInterface.cancel();
                    }
                }).show();
    }
}
