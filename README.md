<h2>🔍 <strong>Why Hashpeek</strong></h2>

<p>One will wonder why need a new hash identifier (hashpeek) when there are so many hash identifiers out there. <strong>You are right to question this tool.</strong></p>

<p>There are many hash identifiers out there but they seem to have one limitation or the other.</p>

<p><strong>Some don't accept input via stdin</strong> making it somehow difficult for scripting.</p>

<p><strong>Others too show outputs that are a hassle to grep</strong> (you need regex gymnastics to grep).</p>

<p><strong>Some too only accept hashes (no files)</strong> and those that accept hashfiles are prone to <strong>spamming your screen with redundant hashtypes.</strong></p>

<p><strong>These are the issues or limitations hashpeek is here to solve.</strong></p>

<hr>
<p>Some files do contain pure hashes hence no cleanup is required and thats okay. But most of the times, hashes are found in dumps which does require extraction. Hashpeek wont let you make a fuss about it. It's got <code>-trunc '{N} `DELIM`'</code> to get you sorted where 'N' handles the field or index of the hash for extraction and 'DELIM' handles the delimiter. Hashpeek also got ignore flag to ignore comments so they don't get parsed as hashes too and to keep the results clean.
  eg. <code> -i '#,/,$'</code>
</p>

<h2>✨ <strong>Features</strong></h2>

<h3>* <strong>Bulk Hash Identification</strong></h3>

<p><code>hashpeek</code> checks hash identification in hash files (hash dumps), and what makes this special about <code>hashpeek</code> is that <strong>instead of spamming your screen with redundant hashtypes, it groups the hashes per similar hashtypes</strong> and then prints it out to you.</p>

<p><strong>Example:</strong><br>
You tried to identify the hashtypes of a file containing hundred hashes (all with the same hashtypes {md5}), instead of printing the hashtype of each hash, <strong>hashpeek groups the hashes as one</strong> (since they all have the same results) and shows only the hashtypes of one representing all.</p>

<hr>

<h3>* <strong>Made for Automation or Scripting-Minded Users</strong></h3>

<p>Most hash identifiers assume the user needs to view the hash type and leave, but <strong>hashpeek allows you to easily pipe and grep it for smooth automation and scripting.</strong> It also <strong>accepts input via stdin.</strong></p>

<hr>

<h2>🛠 <strong>Install</strong></h2>

<pre><code>git clone https://github.com/ph4mished/hashpeek
cd hashpeek
go build hashpeek
./hashpeek -h
</code></pre>

<hr>

<h2>⚙️ <strong>Usage</strong></h2>

<h3><strong>With Hash</strong></h3>
<pre><code>./hashpeek -x 34850bfc40a15d3783447f344db0bcde
</code></pre>

<hr>

<h3><strong>With HashFiles</strong></h3>
<pre><code>./hashpeek -f hashed.txt
</code></pre>

<hr>

<h3><strong>Accepting Input From Stdin</strong></h3>
<p><em>&gt; this is for recursive file parsing</em></p>
<pre><code>ls mydirectory | ./hashpeek -f -
</code></pre>

<hr>

<h3><strong>Extract A Format (grep friendly usage)</strong></h3>
<pre><code>./hashpeek -x 34850bfc40a15d3783447f344db0bcde | grep 'Hashcat Mode:' | grep -v -- '--'
</code></pre>

<hr>

<h2>💡 <strong>Philosophy</strong></h2>

<p><strong>hashpeek aims to be scriptable, extensible — built with power users and automation workflows in mind.</strong></p>
