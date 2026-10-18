package __PKG__;

import android.content.Context;
import android.print.PrintAttributes;
import android.print.PrintDocumentAdapter;
import android.print.PrintManager;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "PrintHtml")
public class PrintHtmlPlugin extends Plugin {
    private WebView printView;

    @PluginMethod
    public void print(final PluginCall call) {
        final String html = call.getString("html", "");
        final String title = call.getString("title", "Reporte");
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    WebView wv = new WebView(getActivity());
                    wv.setWebViewClient(new WebViewClient() {
                        private boolean done = false;

                        @Override
                        public void onPageFinished(WebView view, String url) {
                            if (done) return;
                            done = true;
                            PrintManager pm = (PrintManager) getActivity().getSystemService(Context.PRINT_SERVICE);
                            PrintDocumentAdapter adapter = view.createPrintDocumentAdapter(title);
                            pm.print(title, adapter, new PrintAttributes.Builder().build());
                            call.resolve();
                        }
                    });
                    printView = wv;
                    wv.loadDataWithBaseURL("https://localhost/", html, "text/html", "UTF-8", null);
                } catch (Exception e) {
                    call.reject(String.valueOf(e.getMessage()));
                }
            }
        });
    }

    @PluginMethod
    public void saveDownload(final PluginCall call) {
        try {
            String name = call.getString("name", "archivo");
            String mime = call.getString("mime", "application/octet-stream");
            String data = call.getString("data", "");
            if (android.os.Build.VERSION.SDK_INT < 29) {
                call.reject("sdk");
                return;
            }
            byte[] bytes = android.util.Base64.decode(data, android.util.Base64.DEFAULT);
            android.content.ContentValues v = new android.content.ContentValues();
            v.put(android.provider.MediaStore.Downloads.DISPLAY_NAME, name);
            v.put(android.provider.MediaStore.Downloads.MIME_TYPE, mime);
            v.put(android.provider.MediaStore.Downloads.RELATIVE_PATH, android.os.Environment.DIRECTORY_DOWNLOADS);
            android.content.ContentResolver r = getContext().getContentResolver();
            android.net.Uri uri = r.insert(android.provider.MediaStore.Downloads.EXTERNAL_CONTENT_URI, v);
            if (uri == null) {
                call.reject("nouri");
                return;
            }
            java.io.OutputStream os = r.openOutputStream(uri);
            os.write(bytes);
            os.close();
            JSObject ret = new JSObject();
            ret.put("uri", uri.toString());
            call.resolve(ret);
        } catch (Exception e) {
            call.reject(String.valueOf(e.getMessage()));
        }
    }

    @PluginMethod
    public void openFile(final PluginCall call) {
        try {
            String path = call.getString("path", "");
            String mime = call.getString("mime", "application/pdf");
            java.io.File f = new java.io.File(path);
            android.net.Uri u = androidx.core.content.FileProvider.getUriForFile(getContext(), getContext().getPackageName() + ".fileprovider", f);
            android.content.Intent i = new android.content.Intent(android.content.Intent.ACTION_VIEW);
            i.setDataAndType(u, mime);
            i.addFlags(android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION | android.content.Intent.FLAG_ACTIVITY_NEW_TASK);
            getContext().startActivity(i);
            call.resolve();
        } catch (android.content.ActivityNotFoundException e) {
            call.reject("noviewer");
        } catch (Exception e) {
            call.reject(String.valueOf(e.getMessage()));
        }
    }
}
