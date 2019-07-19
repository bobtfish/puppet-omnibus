# HG changeset patch
# User Maxim Dounin <mdounin@mdounin.ru>
# Date 1493225474 -10800
#      Wed Apr 26 19:51:14 2017 +0300
# Node ID 9e1f56d88fb4e55504fb270db3b1dc642c8fecda
# Parent  7cfefb06849feaaffdb21b6cc6be68b4d1d9a9a5
Added missing "fall through" comments (ticket #1259).

Found by gcc7 (-Wimplicit-fallthrough).

diff --git a/src/core/ngx_murmurhash.c b/src/core/ngx_murmurhash.c
--- a/src/core/ngx_murmurhash.c
+++ b/src/core/ngx_murmurhash.c
@@ -35,8 +35,10 @@ ngx_murmur_hash2(u_char *data, size_t le
     switch (len) {
     case 3:
         h ^= data[2] << 16;
+        /* fall through */
     case 2:
         h ^= data[1] << 8;
+        /* fall through */
     case 1:
         h ^= data[0];
         h *= 0x5bd1e995;
diff --git a/src/http/ngx_http_parse.c b/src/http/ngx_http_parse.c
--- a/src/http/ngx_http_parse.c
+++ b/src/http/ngx_http_parse.c
@@ -1390,6 +1390,7 @@ ngx_http_parse_complex_uri(ngx_http_requ
                 goto done;
             case '+':
                 r->plus_in_uri = 1;
+                /* fall through */
             default:
                 state = sw_usual;
                 *u++ = ch;
@@ -1431,6 +1432,7 @@ ngx_http_parse_complex_uri(ngx_http_requ
                 goto done;
             case '+':
                 r->plus_in_uri = 1;
+                /* fall through */
             default:
                 state = sw_usual;
                 *u++ = ch;
@@ -1478,6 +1480,7 @@ ngx_http_parse_complex_uri(ngx_http_requ
                 goto done;
             case '+':
                 r->plus_in_uri = 1;
+                /* fall through */
             default:
                 state = sw_usual;
                 *u++ = ch;
diff --git a/src/os/unix/ngx_process.c b/src/os/unix/ngx_process.c
--- a/src/os/unix/ngx_process.c
+++ b/src/os/unix/ngx_process.c
@@ -413,6 +413,7 @@ ngx_signal_handler(int signo, siginfo_t 
                 break;
             }
             ngx_debug_quit = 1;
+            /* fall through */
         case ngx_signal_value(NGX_SHUTDOWN_SIGNAL):
             ngx_quit = 1;
             action = ", shutting down";
