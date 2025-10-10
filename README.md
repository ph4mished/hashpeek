<h2>🔍 <strong>Why Hashpeek</strong></h2>

<p>One will wonder why need a new hash identifier (hashpeek) when there are so many hash identifiers out there. <strong>You are right to question this tool.</strong></p>

<p>There are many hash identifiers out there but they seem to have one limitation or the other.</p>

<p><strong>Some don't accept input via stdin</strong> making it somehow difficult for scripting.</p>

<p><strong>Others too show outputs that are a hassle to grep</strong> (you need regex gymnastics to grep).</p>

<p><strong>Some too only accept hashes (no files)</strong> and those that accept hashfiles are prone to <strong>spamming your screen with redundant hashtypes.</strong></p>

<p><strong>These are the issues or limitations hashpeek is here to solve.</strong></p>

<hr>
<h3>📝 <strong>To Do</strong></h3>
<p>1. <b>Libpeek is in the making: </b> Hashpeek is being written so that it could be used as a library too.
<br>
2. <b>More hashtypes will be added to its database</b> 
3. <b>Currently undergoing a rewrite in nim with API first approach.</b>
</p>
<hr>

<h2>✨ <strong>Features</strong></h2>
<h3>* <strong>Segment Extraction</strong></h3>
<p>Some files do contain pure hashes hence no cleanup is required and thats okay. But most of the times, hashes are found in dumps which does require extraction. Hashpeek wont let you make a fuss about it. It's got <br><code>-trunc '{N} `DELIM`'</code><br> to get you sorted where 'N' handles the field or index (0-based index) of the hash for extraction and 'DELIM' handles the delimiter. Hashpeek also got ignore flag to ignore comments so they don't get parsed as hashes too and to keep the results clean.
  eg. <br><code> -i '#,/,$'</code><br>
</p>
<p><strong>Example</strong><br>
These are the contents of 'dump.txt' <pre><code>



[*] Agent A1B2C3D4 returned results.
Administrator:500:aad3b435b51404eeaad3b435b51404ee:209c6174da490caeb422f3fa5a7ae634:::
#These are guests passwords
Guest:501:aad3b435b51404eeaad3b435b51404ee:31d6cfe0d16ae931b73c59d7e0c089c0:::
krbtgt:502:aad3b435b51404eeaad3b435b51404ee:37a7a8d9b814c5eca908617e736c017d:::
admin:1000:aad3b435b51404eeaad3b435b51404ee:5f4dcc3b5aa765d61d8327deb882cf99:::
sql-svc:1106:aad3b435b51404eeaad3b435b51404ee:8d969eef6ecad3c29a3a629280e686cf:::
backup:1107:aad3b435b51404eeaad3b435b51404ee:7c6a180b36896a0a8c02787eeafb0e4c:::
//Mark ending</code></pre>

<code>-trunc</code> will be of great help here. Try <pre><code>hashpeek -f dump.txt -trunc '{3} `:`'</code></pre><br>
<strong>Result</strong><br>
<pre><code>$ hashpeek -f dump.txt -trunc '{3} `:`'
[!] Skipped line  5 : Expected at least 3 fields (got 0) after splitting by ':'.
Content:  [*] Agent A1B2C3D4 returned results.

[!] Skipped line  7 : Expected at least 3 fields (got 0) after splitting by ':'.
Content:  #These are guests passwords

[!] Skipped line  13 : Expected at least 3 fields (got 0) after splitting by ':'.
Content:  //Mark ending

[~] Found 12 hashes in dump.txt

{100.00%} 12/12 Of The Hashes Are:

MD5
    Hashcat Mode: 0
    John Format: raw-md5

NTLM
    Hashcat Mode: 1000
    John Format: nt

LM
    Hashcat Mode: 3000
    John Format: lm

MD4
    Hashcat Mode: 900
    John Format: raw-md4

Double MD5
    Hashcat Mode: 2600
    John Format: --

MD2
    Hashcat Mode: --
    John Format: md2

RIPEMD-128
    Hashcat Mode: --
    John Format: ripemd-128

BLAKE3-128
    Hashcat Mode: --
    John Format: --

FNV-1-128
    Hashcat Mode: --
    John Format: --

Murmur3-128
    Hashcat Mode: --
    John Format: --

Haval-128
    Hashcat Mode: --
    John Format: haval-128-4

SNEFRU-128
    Hashcat Mode: --
    John Format: snefru-128

Skein256-128
    Hashcat Mode: --
    John Format: --

Skein512-128
    Hashcat Mode: --
    John Format: --

Tiger-128
    Hashcat Mode: --
    John Format: --

Tiger128-3
    Hashcat Mode: --
    John Format: --

[[[ End Of File of dump.txt ]]]</code></pre>
Using <code> -i '//,#,[*]' </code> will silence the errors that showed above</p>
<hr>

<h3>* <strong>Hash Extraction From Unstructured Data</strong></h3>

<p><code>hashpeek</code> Some hashes can also be found in messy data logs. These isn't structured data so <code>-trunc</code> or <code>-i</code> can't work here. Do not worry, hashpeek got this too. It hash an extraction engine that can extract hash from any messy log, what it only requires is a minimum length to search for (this is to reduce false positives on the side of the user). No matter how messy the log is just use <code> -e [min-length]</code>.</p>

<p><strong>Example:</strong><br>
You have this log
<pre><code># User login attempts
[INFO] 2025-08-25T10:00:01Z New user 'alice' created. Temp pass: welcome123
[DEBUG] 2025-08-25T10:01:12Z Session token: ####5f4dcc3b5aa765d61d8327deb882cf99###
[ERROR] 2025-08-25T10:02:15Z Password reset failed for 'svc_user'. Hash: d6e0d2c1a5e89c5c7b6b9bccb8b8b8b8b8b8b8b8
Random note: nothing to see here 12345
[WARN] 2025-08-25T10:03:33Z User 'bob' failed login. Token: ####e99a18c428cb38d5f260853678922e03###
Some debug info: 0x4f2a1b
[INFO] Miscellaneous logs ####c3fcd3d76192e4007dfb496cca67e13b###
# End of log#</code></pre> saved as log.txt and you have to extract the hashes from this log, just try <pre><code>hashpeek -f log.txt -e 12</code></pre> where '12' is the minimum required length for extraction so it searches for length of 12 and above</p>

<p><strong>Results</strong><br>
Without Extraction <br>
<pre></code>$ hashpeek -f log.txt

[~] Found 9 hashes in log.txt

{100.00%} 9/9 Of The Hashes Are:                      
[!] Unknown Hash Format!

[[[ End Of File of log.txt ]]]</code></pre><br>
  With Extraction <br>
<pre><code>$ hashpeek -f log.txt -e 12            
 Extracted Hash:  5f4dcc3b5aa765d61d8327deb882cf99

 Extracted Hash:  d6e0d2c1a5e89c5c7b6b9bccb8b8b8b8b8b8b8b8

 Extracted Hash:  e99a18c428cb38d5f260853678922e03                                                           Extracted Hash:  c3fcd3d76192e4007dfb496cca67e13b

[~] Found 4 hashes in log.txt

{75.00%} 3/4 Of The Hashes Are:

MD5
    Hashcat Mode: 0
    John Format: raw-md5

NTLM
    Hashcat Mode: 1000
    John Format: nt

LM
    Hashcat Mode: 3000
    John Format: lm

MD4
    Hashcat Mode: 900
    John Format: raw-md4

Double MD5
    Hashcat Mode: 2600
    John Format: --

MD2
    Hashcat Mode: --
    John Format: md2

RIPEMD-128
    Hashcat Mode: --
    John Format: ripemd-128

BLAKE3-128
    Hashcat Mode: --
    John Format: --

FNV-1-128
    Hashcat Mode: --
    John Format: --

Murmur3-128
    Hashcat Mode: --
    John Format: --

Haval-128
    Hashcat Mode: --
    John Format: haval-128-4

SNEFRU-128
    Hashcat Mode: --
    John Format: snefru-128

Skein256-128
    Hashcat Mode: --
    John Format: --

Skein512-128
    Hashcat Mode: --
    John Format: --

Tiger-128
    Hashcat Mode: --
    John Format: --

Tiger128-3
    Hashcat Mode: --
    John Format: --


{25.00%} 1/4 Of The Hashes Are:

SHA-1
    Hashcat Mode: 100
    John Format: raw-sha1

RIPEMD-160
    Hashcat Mode: 6000
    John Format: ripemd-160

Haval-160
    Hashcat Mode: --
    John Format: --

Double-SHA-1
    Hashcat Mode: 4500
    John Format: --

Tiger-160
    Hashcat Mode: --
    John Format: --

Tiger-160,3
    Hashcat Mode: --
    John Format: --

[[[ End Of File of log.txt ]]]</code></pre></p>

<hr>

<h3>* <strong>Different Output Formats</strong></h3>
<p> hashpeek has three different output formats which are json, CSV and default. These formats are triggered by these flags <br> 
json format => -json<br>
CSV format => -csv<br>
Default formats => null (meaning: no flag is required)
</p>
<hr>

<h3>* <strong>Bulk Hash Identification</strong></h3>

<p><code>hashpeek</code> checks hash identification in hash files (hash dumps), and what makes this special about <code>hashpeek</code> is that <strong>instead of spamming your screen with redundant hashtypes, it groups the hashes per similar hashtypes</strong> and then prints it out to you.</p>

<p><strong>Example:</strong><br>
You have a file saved as mixed.txt with these contents
<pre><code>5f4dcc3b5aa765d61d8327deb882cf99
098f6bcd4621d373cade4e832627b4f6

a94a8fe5ccb19ba61c4c0873d391e987982fbbd3
118e57b1eecd61e54b502055d82aa57f
119a813e67f26dfdcce2a90ab1a82936
11aa5b8ab803fce5c60dc3ccd1e2233d
11ab04c11415e4b2e6c3f731b9934e35
11b77e88cbe690a2a35b458ee228428c
11c757bdec2ba2067edf2512536899f8
11cf2f72b62397bf4bdb316fde20ecf5
11d1344768de2b8eef15e4d76473ae3a
11d6955110fede2e50a8d17477a29186
2fd4e1c67a2d28fced849ee1bb76e7391b93eb12
da39a3ee5e6b4b0d3255bfef95601890afd80709

$2a$10$EIXIXLnT9eV6ZHzg5L58HOS/3BOY4g70hXww2PzC0SvjH0QndOfaK
$2a$12$wzHWZ3Ok7tNq3xqPhjZZCe0DWq0rv6Knt54Pw9CeL67OkkGQAG6De
01084b256a3ab84628e3161c9286de9f
010cbeaa6d609d2fb526606c0803101f
010fae4898685cf661888634f5f68453
01230763e87102e62f2c874a570945d8
012f9ec8f64b85644fc68f543a29b237
0132fed90939abe6dd7b9b1e38da7544
0133d8000b6c29ae202e838d778e8b91
0142b84c7d5ab92691cf9e21fbca9a08
$2b$08$C6UzMDM.H6dfI/f/IKcEeukTFLntP69x4di/S5u4O4KkXm3ErzJK2
$2y$05$N9qo8uLOickgx2ZMRZo4i.EjI5oHjU5oY.kqZmGTQ6jHgZtuq8fVu</pre></code></p>

<hr>

<p><strong>Results</strong><br>
<pre><code>$ hashpeek -f mixed.txt                  
[~] Found 26 hashes in mixed.txt

{73.08%} 19/26 Of The Hashes Are:

MD5
    Hashcat Mode: 0
    John Format: raw-md5
                                                      NTLM
    Hashcat Mode: 1000
    John Format: nt                                   
LM
    Hashcat Mode: 3000
    John Format: lm

MD4
    Hashcat Mode: 900
    John Format: raw-md4

Double MD5                                                Hashcat Mode: 2600
    John Format: --

MD2
    Hashcat Mode: --
    John Format: md2

RIPEMD-128
    Hashcat Mode: --
    John Format: ripemd-128

BLAKE3-128
    Hashcat Mode: --
    John Format: --

FNV-1-128
    Hashcat Mode: --
    John Format: --

Murmur3-128
    Hashcat Mode: --
    John Format: --

Haval-128
    Hashcat Mode: --
    John Format: haval-128-4

SNEFRU-128
    Hashcat Mode: --
    John Format: snefru-128

Skein256-128
    Hashcat Mode: --
    John Format: --

Skein512-128
    Hashcat Mode: --
    John Format: --

Tiger-128
    Hashcat Mode: --
    John Format: --

Tiger128-3
    Hashcat Mode: --
    John Format: --


{11.54%} 3/26 Of The Hashes Are:

SHA-1
    Hashcat Mode: 100
    John Format: raw-sha1

RIPEMD-160
    Hashcat Mode: 6000
    John Format: ripemd-160

Haval-160
    Hashcat Mode: --
    John Format: --

Double-SHA-1
    Hashcat Mode: 4500
    John Format: --

Tiger-160
    Hashcat Mode: --
    John Format: --

Tiger-160,3
    Hashcat Mode: --
    John Format: --


{15.38%} 4/26 Of The Hashes Are:

bcrypt
    Hashcat Mode: 3200
    John Format: bcrypt

Blowfish(OpenBSD)
    Hashcat Mode: 3200
    John Format: bcrypt

Woltlab Burning Board 4.x
    Hashcat Mode: --
    John Format: --

[[[ End Of File of mixed.txt ]]]</code></pre>
</p>

<hr>

<h3>* <strong>Made for Automation or Scripting-Minded Users</strong></h3>

<p>Most hash identifiers assume the user needs to view the hash type and leave, but <strong>hashpeek allows you to easily pipe and grep it for smooth automation and scripting.</strong> It also <strong>accepts input via stdin.</strong></p>


<h2>🛠 <strong>Install</strong></h2>

<pre><code>go install github.com/ph4mished/hashpeek@latest
</code></pre>

<hr>

<h2>⚙️ <strong>Usage</strong></h2>

<h3><strong>With Hash</strong></h3>
<pre><code>hashpeek -x 34850bfc40a15d3783447f344db0bcde
</code></pre>

<hr>

<h3><strong>With HashFiles</strong></h3>
<pre><code> hashpeek -f hashed.txt
</code></pre>

<hr>

<h3><strong>Accepting Input From Stdin</strong></h3>
<p><em>&gt; for recursive file parsing (only when you have a directory of hashfiles)</em></p>
<pre><code>find mydirectory | hashpeek -f -
</code></pre>
<bro>
<b>The content of the files in this folder is too large to show here</b>
<pre><code>$ find hashed | hashpeek -f -
[!] Error: read hashed: is a directory

[[[ End Of File of hashed ]]]


[~] Found 5 hashes in hashed/hashed.txt               
{100.00%} 5/5 Of The Hashes Are:

SHA-256
    Hashcat Mode: 1400                                    John Format: raw-sha256

SHA3-256
    Hashcat Mode: 5000
    John Format: raw-keccak-256

BLAKE2s
    Hashcat Mode: --                                      John Format: --

BLAKE3-256
    Hashcat Mode: --
    John Format: --

RIPEMD-256
    Hashcat Mode: --
    John Format: --

Haval-256
    Hashcat Mode: --
    John Format: haval-256-3

Gost
    Hashcat Mode: --
    John Format: --

GOST R 34.11-94
    Hashcat Mode: 6900
    John Format: gost

Gost-CryptoPro S-Box
    Hashcat Mode: --
    John Format: --

SNEFRU-256
    Hashcat Mode: --
    John Format: snefru-256

EDON-R-256
    Hashcat Mode: --
    John Format: --

Skein256-256
    Hashcat Mode: --
    John Format: skein-256

Skein512-256
    Hashcat Mode: --
    John Format: --

Whirlpool-256
    Hashcat Mode: --
    John Format: --

[[[ End Of File of hashed/hashed.txt ]]]


[~] Found 26 hashes in hashed/mixed.txt

{15.38%} 4/26 Of The Hashes Are:

bcrypt
    Hashcat Mode: 3200
    John Format: bcrypt

Blowfish(OpenBSD)
    Hashcat Mode: 3200
    John Format: bcrypt

Woltlab Burning Board 4.x
    Hashcat Mode: --
    John Format: --


{73.08%} 19/26 Of The Hashes Are:

MD5
    Hashcat Mode: 0
    John Format: raw-md5

NTLM
    Hashcat Mode: 1000
    John Format: nt

LM
    Hashcat Mode: 3000
    John Format: lm

MD4
    Hashcat Mode: 900
    John Format: raw-md4

Double MD5
    Hashcat Mode: 2600
    John Format: --

MD2
    Hashcat Mode: --
    John Format: md2

RIPEMD-128
    Hashcat Mode: --
    John Format: ripemd-128

BLAKE3-128
    Hashcat Mode: --
    John Format: --

FNV-1-128
    Hashcat Mode: --
    John Format: --

Murmur3-128
    Hashcat Mode: --
    John Format: --

Haval-128
    Hashcat Mode: --
    John Format: haval-128-4

SNEFRU-128
    Hashcat Mode: --
    John Format: snefru-128

Skein256-128
    Hashcat Mode: --
    John Format: --

Skein512-128
    Hashcat Mode: --
    John Format: --

Tiger-128
    Hashcat Mode: --
    John Format: --

Tiger128-3
    Hashcat Mode: --
    John Format: --


{11.54%} 3/26 Of The Hashes Are:

SHA-1
    Hashcat Mode: 100
    John Format: raw-sha1

RIPEMD-160
    Hashcat Mode: 6000
    John Format: ripemd-160

Haval-160
    Hashcat Mode: --
    John Format: --

Double-SHA-1
    Hashcat Mode: 4500
    John Format: --

Tiger-160
    Hashcat Mode: --
    John Format: --

Tiger-160,3
    Hashcat Mode: --
    John Format: --

[[[ End Of File of hashed/mixed.txt ]]]


[~] Found 606 hashes in hashed/net_hashes.txt

{100.00%} 606/606 Of The Hashes Are:

MD5
    Hashcat Mode: 0
    John Format: raw-md5

NTLM
    Hashcat Mode: 1000
    John Format: nt

LM
    Hashcat Mode: 3000
    John Format: lm

MD4
    Hashcat Mode: 900
    John Format: raw-md4

Double MD5
    Hashcat Mode: 2600
    John Format: --

MD2
    Hashcat Mode: --
    John Format: md2

RIPEMD-128
    Hashcat Mode: --
    John Format: ripemd-128

BLAKE3-128
    Hashcat Mode: --
    John Format: --

FNV-1-128
    Hashcat Mode: --
    John Format: --

Murmur3-128
    Hashcat Mode: --
    John Format: --

Haval-128
    Hashcat Mode: --
    John Format: haval-128-4

SNEFRU-128
    Hashcat Mode: --
    John Format: snefru-128

Skein256-128
    Hashcat Mode: --
    John Format: --

Skein512-128
    Hashcat Mode: --
    John Format: --

Tiger-128
    Hashcat Mode: --
    John Format: --

Tiger128-3
    Hashcat Mode: --
    John Format: --

[[[ End Of File of hashed/net_hashes.txt ]]]


[~] Found 606 hashes in hashed/net_hashes.txt

{100.00%} 606/606 Of The Hashes Are:

MD5
    Hashcat Mode: 0
    John Format: raw-md5

NTLM
    Hashcat Mode: 1000
    John Format: nt

LM
    Hashcat Mode: 3000
    John Format: lm

MD4
    Hashcat Mode: 900
    John Format: raw-md4

Double MD5
    Hashcat Mode: 2600
    John Format: --

MD2
    Hashcat Mode: --
    John Format: md2

RIPEMD-128
    Hashcat Mode: --
    John Format: ripemd-128

BLAKE3-128
    Hashcat Mode: --
    John Format: --

FNV-1-128
    Hashcat Mode: --
    John Format: --

Murmur3-128
    Hashcat Mode: --
    John Format: --

Haval-128
    Hashcat Mode: --
    John Format: haval-128-4

SNEFRU-128
    Hashcat Mode: --
    John Format: snefru-128

Skein256-128
    Hashcat Mode: --
    John Format: --

Skein512-128
    Hashcat Mode: --
    John Format: --

Tiger-128
    Hashcat Mode: --
    John Format: --

Tiger128-3
    Hashcat Mode: --
    John Format: --

[[[ End Of File of hashed/net_hashes.txt ]]]</code></pre></p>

<hr>

<h3><strong>Extract A Format (grep friendly usage)</strong></h3>
<pre><code>hashpeek -x 34850bfc40a15d3783447f344db0bcde | grep 'Hashcat Mode:' | grep -v -- '--'
</code></pre><br>
<strong>Results</strong>
<pre><code>Hashcat Mode: 0
    Hashcat Mode: 1000
    Hashcat Mode: 3000
    Hashcat Mode: 900
    Hashcat Mode: 2600</code></pre>

<hr>

<h2>💡 <strong>Philosophy</strong></h2>

<p><strong>hashpeek aims to be scriptable, extensible — built with power users and automation workflows in mind.</strong></p>
