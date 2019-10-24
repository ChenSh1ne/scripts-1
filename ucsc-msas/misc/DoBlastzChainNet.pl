<!DOCTYPE html>
<html class="client-nojs" lang="en" dir="ltr">
<head>
<meta charset="UTF-8"/>
<title>DoBlastzChainNet.pl - genomewiki</title>
<script>document.documentElement.className = document.documentElement.className.replace( /(^|\s)client-nojs(\s|$)/, "$1client-js$2" );</script>
<script>(window.RLQ=window.RLQ||[]).push(function(){mw.config.set({"wgCanonicalNamespace":"","wgCanonicalSpecialPageName":false,"wgNamespaceNumber":0,"wgPageName":"DoBlastzChainNet.pl","wgTitle":"DoBlastzChainNet.pl","wgCurRevisionId":24830,"wgRevisionId":24830,"wgArticleId":9521,"wgIsArticle":true,"wgIsRedirect":false,"wgAction":"view","wgUserName":null,"wgUserGroups":["*"],"wgCategories":["Cluster FAQ","Technical FAQ"],"wgBreakFrames":false,"wgPageContentLanguage":"en","wgPageContentModel":"wikitext","wgSeparatorTransformTable":["",""],"wgDigitTransformTable":["",""],"wgDefaultDateFormat":"dmy","wgMonthNames":["","January","February","March","April","May","June","July","August","September","October","November","December"],"wgMonthNamesShort":["","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"wgRelevantPageName":"DoBlastzChainNet.pl","wgRelevantArticleId":9521,"wgRequestId":"W3LxwZj9GROq2w0ZGrREtgAAAAI","wgIsProbablyEditable":false,"wgRestrictionEdit":[],"wgRestrictionMove":[]});mw.loader.state({"site.styles":"ready","noscript":"ready","user.styles":"ready","user":"ready","user.options":"loading","user.tokens":"loading","mediawiki.legacy.shared":"ready","mediawiki.legacy.commonPrint":"ready","mediawiki.sectionAnchor":"ready","mediawiki.skinning.interface":"ready","mediawiki.skinning.content.externallinks":"ready","skins.monobook.styles":"ready"});mw.loader.implement("user.options@0j3lz3q",function($,jQuery,require,module){mw.user.options.set({"variant":"en"});});mw.loader.implement("user.tokens@0ecozdl",function ( $, jQuery, require, module ) {
mw.user.tokens.set({"editToken":"+\\","patrolToken":"+\\","watchToken":"+\\","csrfToken":"+\\"});/*@nomin*/;

});mw.loader.load(["mediawiki.toc","mediawiki.action.view.postEdit","site","mediawiki.page.startup","mediawiki.user","mediawiki.hidpi","mediawiki.page.ready","mediawiki.searchSuggest"]);});</script>
<link rel="stylesheet" href="/load.php?debug=false&amp;lang=en&amp;modules=mediawiki.legacy.commonPrint%2Cshared%7Cmediawiki.sectionAnchor%7Cmediawiki.skinning.content.externallinks%7Cmediawiki.skinning.interface%7Cskins.monobook.styles&amp;only=styles&amp;skin=monobook"/>
<script async="" src="/load.php?debug=false&amp;lang=en&amp;modules=startup&amp;only=scripts&amp;skin=monobook"></script>
<!--[if IE 6]><link rel="stylesheet" href="/skins/MonoBook/IE60Fixes.css?303" media="screen"/><![endif]--><!--[if IE 7]><link rel="stylesheet" href="/skins/MonoBook/IE70Fixes.css?303" media="screen"/><![endif]-->
<meta name="ResourceLoaderDynamicStyles" content=""/>
<meta name="generator" content="MediaWiki 1.29.1"/>
<link rel="shortcut icon" href="/favicon.ico"/>
<link rel="search" type="application/opensearchdescription+xml" href="/opensearch_desc.php" title="genomewiki (en)"/>
<link rel="EditURI" type="application/rsd+xml" href="http://genomewiki.ucsc.edu/api.php?action=rsd"/>
<link rel="alternate" type="application/atom+xml" title="genomewiki Atom feed" href="/index.php?title=Special:RecentChanges&amp;feed=atom"/>
</head>
<body class="mediawiki ltr sitedir-ltr mw-hide-empty-elt ns-0 ns-subject page-DoBlastzChainNet_pl rootpage-DoBlastzChainNet_pl skin-monobook action-view"><div id="globalWrapper">
		<div id="column-content">
			<div id="content" class="mw-body" role="main">
				<a id="top"></a>
				
				<div class="mw-indicators mw-body-content">
</div>
				<h1 id="firstHeading" class="firstHeading" lang="en">DoBlastzChainNet.pl</h1>
				
				<div id="bodyContent" class="mw-body-content">
					<div id="siteSub">From genomewiki</div>
					<div id="contentSub"></div>
										<div id="jump-to-nav" class="mw-jump">Jump to: <a href="#column-one">navigation</a>, <a href="#searchInput">search</a></div>

					<!-- start content -->
					<div id="mw-content-text" lang="en" dir="ltr" class="mw-content-ltr"><div id="toc" class="toc"><div id="toctitle" class="toctitle"><h2>Contents</h2></div>
<ul>
<li class="toclevel-1 tocsection-1"><a href="#Licensing"><span class="tocnumber">1</span> <span class="toctext">Licensing</span></a></li>
<li class="toclevel-1 tocsection-2"><a href="#Prerequisites"><span class="tocnumber">2</span> <span class="toctext">Prerequisites</span></a></li>
<li class="toclevel-1 tocsection-3"><a href="#Compute_resources"><span class="tocnumber">3</span> <span class="toctext">Compute resources</span></a></li>
<li class="toclevel-1 tocsection-4"><a href="#Parasol_Job_Control_System"><span class="tocnumber">4</span> <span class="toctext">Parasol Job Control System</span></a></li>
<li class="toclevel-1 tocsection-5"><a href="#Install_scripts_and_kent_command_line_utilities"><span class="tocnumber">5</span> <span class="toctext">Install scripts and kent command line utilities</span></a></li>
<li class="toclevel-1 tocsection-6"><a href="#PATH_setup"><span class="tocnumber">6</span> <span class="toctext">PATH setup</span></a></li>
<li class="toclevel-1 tocsection-7"><a href="#Working_directory_hierarchy"><span class="tocnumber">7</span> <span class="toctext">Working directory hierarchy</span></a></li>
<li class="toclevel-1 tocsection-8"><a href="#Obtain_genome_sequences"><span class="tocnumber">8</span> <span class="toctext">Obtain genome sequences</span></a></li>
<li class="toclevel-1 tocsection-9"><a href="#lastz_parameter_file"><span class="tocnumber">9</span> <span class="toctext">lastz parameter file</span></a></li>
<li class="toclevel-1 tocsection-10"><a href="#perform_alignment"><span class="tocnumber">10</span> <span class="toctext">perform alignment</span></a></li>
<li class="toclevel-1 tocsection-11"><a href="#Monitor_progress"><span class="tocnumber">11</span> <span class="toctext">Monitor progress</span></a></li>
<li class="toclevel-1 tocsection-12"><a href="#Reciprocal_Best"><span class="tocnumber">12</span> <span class="toctext">Reciprocal Best</span></a></li>
<li class="toclevel-1 tocsection-13"><a href="#Swap"><span class="tocnumber">13</span> <span class="toctext">Swap</span></a></li>
<li class="toclevel-1 tocsection-14"><a href="#Track_Hub_files"><span class="tocnumber">14</span> <span class="toctext">Track Hub files</span></a></li>
<li class="toclevel-1 tocsection-15"><a href="#How_does_this_process_work"><span class="tocnumber">15</span> <span class="toctext">How does this process work</span></a></li>
</ul>
</div>

<h2><span class="mw-headline" id="Licensing">Licensing</span></h2>
<p>For commercial use of these toolsets, please note the license considerations for the
kent source tools at the: <a rel="nofollow" class="external text" href="https://genome-store.ucsc.edu/">Genome Store</a>
</p>
<h2><span class="mw-headline" id="Prerequisites">Prerequisites</span></h2>
<p>This discussion assumes you are familiar with <a rel="nofollow" class="external text" href="https://en.wikipedia.org/wiki/Unix">Unix</a>
<a rel="nofollow" class="external text" href="https://en.wikipedia.org/wiki/Unix_shell">shell</a> command line programming and scripting.
You will be encountering and interacting with <a rel="nofollow" class="external text" href="https://en.wikipedia.org/wiki/C_shell">csh/tcsh</a>,
<a rel="nofollow" class="external text" href="https://en.wikipedia.org/wiki/Bash_(Unix_shell)">bash</a>, <a rel="nofollow" class="external text" href="https://en.wikipedia.org/wiki/Perl">perl</a>,
and <a rel="nofollow" class="external text" href="https://en.wikipedia.org/wiki/Python_(programming_language)">python</a> scripting languages.
You will need at least one computer with several <a rel="nofollow" class="external text" href="https://en.wikipedia.org/wiki/Multi-core_processor">CPU cores</a>,
preferably a multiple <a rel="nofollow" class="external text" href="https://en.wikipedia.org/wiki/Computer_cluster">compute cluster</a> system or equivalent
in a <a rel="nofollow" class="external text" href="https://en.wikipedia.org/wiki/Cloud_computing">cloud computing</a> environment.
</p><p>This entire discussion assumes the <a rel="nofollow" class="external text" href="https://en.wikipedia.org/wiki/Bash_(Unix_shell)">bash shell</a>
is the user's unix shell.
</p>
<h2><span class="mw-headline" id="Compute_resources">Compute resources</span></h2>
<p>For any reasonable sized genome assemblies, this procedure will require cluster compute resources.
Typical compute times can range from 1 to 2 days with 100 CPUs(cores).  Much longer compute times
will be seen for high contig count genome assemblies (hundreds of thousands of contigs) or for
assemblies that are not well repeat masked.  Please note this scatter plot and histogram
showing compute time vs. genome size for alignments performed at <a rel="nofollow" class="external text" href="https://ucscgenomics.soe.ucsc.edu/">UCSC</a>
</p><p><a href="/index.php/File:SizeVsTime.png" class="image"><img alt="SizeVsTime.png" src="/images/thumb/5/5d/SizeVsTime.png/100px-SizeVsTime.png" width="100" height="67" class="thumbborder" srcset="/images/thumb/5/5d/SizeVsTime.png/150px-SizeVsTime.png 1.5x, /images/thumb/5/5d/SizeVsTime.png/200px-SizeVsTime.png 2x" /></a> <a href="/index.php/File:LastzProcessingTimeHistogram.png" class="image"><img alt="LastzProcessingTimeHistogram.png" src="/images/thumb/8/8a/LastzProcessingTimeHistogram.png/100px-LastzProcessingTimeHistogram.png" width="100" height="67" class="thumbborder" srcset="/images/thumb/8/8a/LastzProcessingTimeHistogram.png/150px-LastzProcessingTimeHistogram.png 1.5x, /images/thumb/8/8a/LastzProcessingTimeHistogram.png/200px-LastzProcessingTimeHistogram.png 2x" /></a>
</p>
<h2><span class="mw-headline" id="Parasol_Job_Control_System">Parasol Job Control System</span></h2>
<p>For cluster compute resources <a rel="nofollow" class="external text" href="https://ucscgenomics.soe.ucsc.edu/">UCSC</a> uses the parasol
job control system.  The scripts and programs used here expect to find the <a href="/index.php/Parasol_job_control_system" title="Parasol job control system">Parasol_job_control_system</a> in place
and operational.
</p>
<h2><span class="mw-headline" id="Install_scripts_and_kent_command_line_utilities">Install scripts and kent command line utilities</span></h2>
<p>This is a bit of a kludge at this time (April 2018), we are working on a cleaner
distribution of these scripts.  As was mentioned in the <a href="/index.php/Parasol_job_control_system" title="Parasol job control system">Parasol_job_control_system</a>
setup, the kent command line binaries and these scripts are going to reside in <b>/data/bin/</b>
and <b>/data/scripts/</b>.  This is merely a style custom to keep scripts separate
from binaries, this is not strictly necessary to keep them separate.
</p>
<pre>

 mkdir -p /data/scripts /data/bin
 chmod 755 /data/scripts /data/bin

 rsync -a rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/ /data/bin/
 git archive --remote=git://genome-source.soe.ucsc.edu/kent.git \
  --prefix=kent/ HEAD src/hg/utils/automation \
     | tar vxf - -C /data/scripts --strip-components=5 \
        --exclude='kent/src/hg/utils/automation/incidentDb' \
      --exclude='kent/src/hg/utils/automation/configFiles' \
      --exclude='kent/src/hg/utils/automation/ensGene' \
      --exclude='kent/src/hg/utils/automation/genbank' \
      --exclude='kent/src/hg/utils/automation/lastz_D' \
      --exclude='kent/src/hg/utils/automation/openStack'
  wget -O /data/bin/bedSingleCover.pl 'http://genome-source.soe.ucsc.edu/gitweb/?p=kent.git;a=blob_plain;f=src/utils/bedSingleCover.pl'

</pre>
<p><b>NOTE:</b> A copy of the <b>lastz</b> binary is included in the rsync download
of binaries from hgdownload.  It is named <b>lastz-1.04.00</b> to identify the version.
Source for lastz can be obtained from <a rel="nofollow" class="external text" href="https://github.com/lastz/lastz">lastz github.</a>
</p>
<h2><span class="mw-headline" id="PATH_setup">PATH setup</span></h2>
<p>Add or verify the two directories <b>/data/bin</b> and <b>/data/scripts</b> are added
to the shell <b>PATH</b> environment.  This can be added simply to the <b>.bashrc</b> file in
your home directory:
</p>
<pre>echo 'export PATH=/data/bin:/data/scripts:$PATH' &gt;&gt; $HOME/.bashrc
</pre>
<p>Then, <b>source</b> that file to add that to this current shell:
</p>
<pre>. $HOME/.bashrc
</pre>
<p>Verify you see those pathnames on the PATH variable:
</p>
<pre>echo $PATH
/data/bin:/data/scripts:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/centos/.local/bin:/home/centos/bin
</pre>
<h2><span class="mw-headline" id="Working_directory_hierarchy">Working directory hierarchy</span></h2>
<p>It is best to organize your work in a directory hierarchy.  For example maintain all your
genome sequences in:
</p>
<pre> /data/genomes/
 /data/genomes/hg38/
 /data/genomes/mm10/
 /data/genomes/dm6/
 /data/genomes/ce11/
 ... etc ...
</pre>
<p>Where those database directories can have the <b>2bit</b> files, chrom.sizes, and
track construction directories, for example:
</p>
<pre> /data/genomes/dm6/dm6.2bit
 /data/genomes/dm6/dm6.chrom.sizes
 /data/genomes/dm6/trackData/
</pre>
<p>Such organizations are a personal preference custom.  However you do this, keep
it consistent to make it easier to use scripts on multiple sequences.
</p>
<h2><span class="mw-headline" id="Obtain_genome_sequences">Obtain genome sequences</span></h2>
<p>Genome sequences from the <b>U.C. Santa Cruz Genomics Institute</b> can be obtained
directly from the <b>hgdownload</b> server via rsync.  For example
</p>
<pre>mkdir /data/genomes/dm6
cd /data/genomes/dm6
rsync -avzP \
   rsync://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips/dm6.2bit .
rsync -avzP \
   rsync://hgdownload.soe.ucsc.edu/goldenPath/dm6/bigZips/dm6.chrom.sizes .
ls -og
-rw-rw-r--. 1 36969050 Aug 28  2014 dm6.2bit
-rw-rw-r--. 1    45055 Aug 28  2014 dm6.chrom.sizes
</pre>
<p>Genome sequences from the NCBI/Entrez/Genbank system can be found via the
assembly_summary.txt text listing information files, for example <b>invertebrate</b> genomes:
</p>
<pre>

 wget -O /tmp/invertebrate.assembly_summary.txt 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/invertebrate/assembly_summary.txt'

</pre>
<p>Looking for the Anopheles genome:
</p>
<pre>

 grep -w Anopheles /tmp/invertebrate.assembly_summary.txt 
 GCF_000005575.2 PRJNA163        SAMN02952903    AAAB00000000.1  representative genome   180454  7165    Anopheles gambiae str. PEST     strain=PEST            latest   Chromosome      Major   Full    2006/10/16      AgamP3  The International Consortium for the Sequencing of Anopheles Genome     GCA_000005575.1 different       ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/575/GCF_000005575.2_AgamP3

</pre>
<p>Note the Assembly identification from the ftp path <b>GCF_000005575.2_AgamP3</b>,
working with that sequence, using the <b>rsync</b> service in place of the <b>FTP</b>:
</p>
<pre>

 mkdir /data/genomes/dm6/trackData/GCF_000005575.2_AgamP3
 cd /data/genomes/dm6/trackData/GCF_000005575.2_AgamP3
 rsync -L -a -P rsync://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/575/GCF_000005575.2_AgamP3/GCF_000005575.2_AgamP3_genomic.fna.gz ./
 rsync -L -a -P \
     rsync://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/575/GCF_000005575.2_AgamP3/GCF_000005575.2_AgamP3_assembly_report.txt ./
 ls -og
 total 79908
 -rw-rw-r--. 1   811394 Mar  7  2017 GCF_000005575.2_AgamP3_assembly_report.txt
 -rw-rw-r--. 1 81010275 Jun 15  2016 GCF_000005575.2_AgamP3_genomic.fna.gz

</pre>
<p>The assembly_report.txt file is useful to have for the meta-data information it has about the assembly.
The <b>fna.gz</b> file needs to be in <b>2bit</b> format for the processing system, and the <b>chrom.sizes</b> made from the <b>2bit</b>:
</p>
<pre>faToTwoBit GCF_000005575.2_AgamP3_genomic.fna.gz GCF_000005575.2_AgamP3.2bit
twoBitInfo GCF_000005575.2_AgamP3.2bit stdout | sort -k2,2nr &gt; GCF_000005575.2_AgamP3.chrom.sizes
ls -og
total 156132
-rw-rw-r--. 1 77912208 Apr  6 03:48 GCF_000005575.2_AgamP3.2bit
-rw-rw-r--. 1   138303 Apr  6 03:48 GCF_000005575.2_AgamP3.chrom.sizes
-rw-rw-r--. 1   811394 Mar  7  2017 GCF_000005575.2_AgamP3_assembly_report.txt
-rw-rw-r--. 1 81010275 Jun 15  2016 GCF_000005575.2_AgamP3_genomic.fna.gz
</pre>
<h2><span class="mw-headline" id="lastz_parameter_file">lastz parameter file</span></h2>
<p><b>SEE ALSO:</b> <a href="/index.php/Lastz_DEF_file_parameters" title="Lastz DEF file parameters">lastz DEF file parameters</a>
</p><p>The <b>DEF</b> file is used with the script to specify alignment parameters to <b>lastz</b> and
the <b>axtChain</b> operations.  The example
for <b>dm6</b> target vs. <b>A. gambiae</b> query sequence, loose parameters are used
for this <b>distant</b> alignment:
</p>
<pre>cat DEF
# dm6 vs GCF_000005575.2_AgamP3
PATH=/data/bin:/data/scripts
BLASTZ=/data/bin/lastz-1.04.00
BLASTZ_H=2000
BLASTZ_Y=3400
BLASTZ_L=4000
BLASTZ_K=2200
BLASTZ_Q=/data/lastz/HoxD55.q

# TARGET: D. melanogaster dm6
SEQ1_DIR=/data/genomes/dm6/dm6.2bit
SEQ1_LEN=/data/genomes/dm6/dm6.chrom.sizes
SEQ1_CHUNK=32100000
SEQ1_LAP=10000
SEQ1_LIMIT=18

# QUERY: GCF_000005575.2_AgamP3
SEQ2_DIR=/data/genomes/dm6/trackData/GCF_000005575.2_AgamP3/GCF_000005575.2_AgamP3.2bit
SEQ2_LEN=/data/genomes/dm6/trackData/GCF_000005575.2_AgamP3/GCF_000005575.2_AgamP3.chrom.sizes
SEQ2_CHUNK=1000000
SEQ2_LIMIT=2000
SEQ2_LAP=0

BASE=/data/genomes/dm6/trackData/GCF_000005575.2_AgamP3
TMPDIR=/dev/shm
</pre>
<p><b>NOTE:</b> UCSC tends to keep options for running alignments to approximately four
category sets:
</p>
<ul><li> human to other primates</li>
<li> human to other mammals</li>
<li> human to more distant vertebrates</li>
<li> fly and worm alignments and other such distant organisms</li></ul>
<p>Many examples of DEF files and chaining arguments can be found in the record of alignments
at <b>UCSC</b> in the source tree <b>make doc</b> files.  For example, alignments to human/hg38:
<a rel="nofollow" class="external text" href="http://genome-source.cse.ucsc.edu/gitweb/?p=kent.git;a=blob;f=src/hg/makeDb/doc/hg38/lastzRuns.txt">hg38 lastz</a>
and the 100-way alignment: <a href="/index.php/Hg38_100-way_conservation_lastz_parameters" title="Hg38 100-way conservation lastz parameters">Hg38_100-way_conservation_lastz_parameters</a>
</p><p>Many experiments have been tried over time.  To keep it simple:
</p>
<ul><li> <b>human to other primates</b></li></ul>
<pre>BLASTZ_M=254
BLASTZ_O=600
BLASTZ_E=150
BLASTZ_K=4500
BLASTZ_Y=15000
BLASTZ_T=2
BLASTZ_Q=/scratch/data/blastz/human_chimp.v2.q
# Where human_chimp.v2.q is:
#  A    C    G    T
#   90 -330 -236 -356
# -330  100 -318 -236
# -236 -318  100 -330
# -356 -236 -330   90
-chainMinScore=5000 -chainLinearGap=medium
</pre>
<ul><li> <b>human to other mammals</b></li></ul>
<pre>BLASTZ_O=400
BLASTZ_E=30
BLASTZ_M=254
# default BLASTZ_Q score matrix:
#       A     C     G     T
# A    91  -114   -31  -123
# C  -114   100  -125   -31
# G   -31  -125   100  -114
# T  -123   -31  -114    91
-chainMinScore=3000 -chainLinearGap=medium
</pre>
<ul><li> <b>human to more distant vertebrates</b></li></ul>
<pre>BLASTZ_M=50
BLASTZ_Y=3400
BLASTZ_L=6000
BLASTZ_K=2200
BLASTZ_Q=/scratch/data/blastz/HoxD55.q
# HoxD55.q matrix is:
#     A    C    G    T
#    91  -90  -25 -100
#   -90  100 -100  -25
#   -25 -100  100  -90
#  -100  -25  -90  91
-chainMinScore=5000 -chainLinearGap=loose
</pre>
<ul><li> <b>fly and worm alignments and other such distant organisms</b></li></ul>
<pre>BLASTZ_H=2000
BLASTZ_Y=3400
BLASTZ_L=4000
BLASTZ_K=2200
BLASTZ_Q=/data/lastz/HoxD55.q
# HoxD55.q matrix is:
#     A    C    G    T
#    91  -90  -25 -100
#   -90  100 -100  -25
#   -25 -100  100  -90
#  -100  -25  -90  91
-chainMinScore=1000 -chainLinearGap=loose
</pre>
<h2><span class="mw-headline" id="perform_alignment">perform alignment</span></h2>
<p>After the DEF file is established, verify the files specified in it are actually
present at the locations specified:
</p>
<pre>egrep "_DIR|_LEN" DEF | sed -e 's/.*=//;' | xargs ls -og
-rw-rw-r--. 1 36969050 Aug 28  2014 /data/genomes/dm6/dm6.2bit
-rw-rw-r--. 1    45055 Aug 28  2014 /data/genomes/dm6/dm6.chrom.sizes
-rw-rw-r--. 1 77912208 Apr  6 03:48 /data/genomes/dm6/trackData/GCF_000005575.2_AgamP3/GCF_000005575.2_AgamP3.2bit
-rw-rw-r--. 1   138303 Apr  6 03:48 /data/genomes/dm6/trackData/GCF_000005575.2_AgamP3/GCF_000005575.2_AgamP3.chrom.sizes
</pre>
<p>Use a <b>screen</b> to keep this command
attached to a terminal that you can detach from and reattach to at a later time.
For large genomes, or with fewer CPU cores available, this command can run for
many days.  Time the operation of the command and record all output from it for later analysis
if any problems arise from the operation:
</p>
<pre>screen -S dm6.GCF_000005575
time (/data/scripts/doBlastzChainNet.pl `pwd`/DEF -verbose=2 -noDbNameCheck \
 -workhorse=localhost -bigClusterHub=localhost -skipDownload \
   -dbHost=localhost -smallClusterHub=localhost \
     -trackHub -fileServer=localhost -syntenicNet) &gt; do.log 2&gt;&amp;1 &amp;
</pre>
<p>The screen <b>-S dm6.GCF_000005575</b> gives a name to the terminal so you can
find it later in a listing of a number of screens.  To detach from the
running terminal, use two key presses:
</p>
<pre><b>"Ctrl-a Ctrl-d"</b>
</pre>
<p>to reattach to this screen: <b>screen -r -d dm6.GCF_000005575</b>
</p><p><b>BEWARE</b> the drawback of the <b>screen</b> is that you can
accidentally <b>exit</b> the shell while in the <b>screen</b> and you thus lose it.
The processes that were attached to that shell can continue if they do not
respond to the <b>SIGHUP</b> signal.  To avoid this side-effect, develop a habit
of <b>always</b> exiting a shell with the two key presses <b>"Ctrl-a Ctrl-d"</b>,
in a <b>shell</b> that is not in a <b>screen</b> it will merely echo those keystrokes
and do nothing.
</p>
<h2><span class="mw-headline" id="Monitor_progress">Monitor progress</span></h2>
<p>To determine which <b>step</b> the process is working on, in this working directory,
look for the word <b>step</b> in the <b>do.log</b> file:
</p>
<pre>cd /data/genomes/dm6/trackData/GCF_000005575.2_AgamP3
grep -w step do.log
HgStepManager: executing from step 'partition' through step 'syntenicNet'.
HgStepManager: executing step 'partition' Fri Apr  6 04:50:34 2018.
HgStepManager: executing step 'blastz' Fri Apr  6 04:50:46 2018.
</pre>
<p>To view the <b>parasol</b> status of your <b>batch</b>:
</p>
<pre>parasol list batches
#user     run   wait   done crash pri max cpu  ram  plan min batch
centos    323  18446  10283     0  10  -1   1  2.0g  323   0 /data/genomes/dm6/trackData/GCF_000005575.2_AgamP3/run.blastz/
</pre>
<p>To view the status of that particular <b>batch</b>:
</p>
<pre>cd /data/genomes/dm6/trackData/GCF_000005575.2_AgamP3/run.blastz/
para time
29052 jobs in batch
16647 jobs (including everybody's) in Parasol queue or running.
Checking finished jobs
..........................
Completed: 12405 of 29052 jobs
Jobs currently running: 323
In queue waiting: 16324 jobs
CPU time in finished jobs:      81145s    1352.42m    22.54h    0.94d  0.003 y
IO &amp; Wait Time:                142817s    2380.28m    39.67h    1.65d  0.005 y
Time in running jobs:            4076s      67.93m     1.13h    0.05d  0.000 y
Average job time:                  18s       0.30m     0.01h    0.00d
Longest running job:               43s       0.72m     0.01h    0.00d
Longest finished job:              72s       1.20m     0.02h    0.00d
Submission to last job:           718s      11.97m     0.20h    0.01d
Estimated complete:               930s      15.51m     0.26h    0.01d
</pre>
<p>This example happens to be running on an <b>Open Stack</b> cluster with 323 allocated CPU cores:
</p>
<pre>parasol status
CPUs total: 323
CPUs free: 0
CPUs busy: 323
Nodes total: 20
Nodes dead: 0
Nodes sick?: 0
Jobs running:  323
Jobs waiting:  14977
Jobs finished: 13752
Jobs crashed:  0
Spokes free: 30
Spokes busy: 0
Spokes dead: 0
Active batches: 1
Total batches: 1
Active users: 1
Total users: 1
Days up: 0.012685
Version: 12.18
</pre>
<p>When a <b>parasol batch</b> is completed, this scripting process leaves a <b>run.time</b> file
in the <b>batch</b> directory where you can see what type of cluster time you have used:
</p>
<pre>cd /data/genomes/dm6/trackData/GCF_000005575.2_AgamP3/run.blastz
cat run.time
Completed: 29052 of 29052 jobs
CPU time in finished jobs:     149061s    2484.35m    41.41h    1.73d  0.005 y
IO &amp; Wait Time:                268812s    4480.20m    74.67h    3.11d  0.009 y
Average job time:                  14s       0.24m     0.00h    0.00d
Longest finished job:              72s       1.20m     0.02h    0.00d
Submission to last job:          1312s      21.87m     0.36h    0.02d
Estimated complete:                 0s       0.00m     0.00h    0.00d
</pre>
<p>For small genomes such as the two in this example, the steps after the <b>lastz</b> alignment
can proceed rapidly:
</p>
<pre>grep -w step do.log
HgStepManager: executing from step 'partition' through step 'syntenicNet'.
HgStepManager: executing step 'partition' Fri Apr  6 04:50:34 2018.
HgStepManager: executing step 'blastz' Fri Apr  6 04:50:46 2018.
HgStepManager: executing step 'cat' Fri Apr  6 05:13:52 2018.
HgStepManager: executing step 'chainRun' Fri Apr  6 05:14:12 2018.
HgStepManager: executing step 'chainMerge' Fri Apr  6 05:15:49 2018.
HgStepManager: executing step 'net' Fri Apr  6 05:15:58 2018.
HgStepManager: executing step 'load' Fri Apr  6 05:17:06 2018.
HgStepManager: executing step 'download' Fri Apr  6 05:17:35 2018.
HgStepManager: executing step 'cleanup' Fri Apr  6 05:17:36 2018.
HgStepManager: executing step 'syntenicNet' Fri Apr  6 05:17:42 2018.
</pre>
<p>The <b>syntenicNet</b> is the last step in this process, the <b>do.log</b> timing
will indicate the full time for this alignment:
</p>
<pre>tail -3 do.log
real    27m20.456s
user    0m0.720s
sys     0m0.394s
</pre>
<p>And <b>featureBits</b> measurements have taken place to indicate the amount of
coverage of the <b>target</b> genome by the <b>query</b> genome, for both the
fundamental alignment, and the <b>syntenic</b> filtered alignment:
</p>
<pre>ls fb.*
fb.dm6.chain.GCF_000005575.2_AgamP3Link.txt
fb.dm6.chainSyn.GCF_000005575.2_AgamP3Link.txt
</pre>
<pre>cat fb.*
19155294 bases of 143726002 (13.328%) in intersection
1617815 bases of 143726002 (1.126%) in intersection
</pre>
<h2><span class="mw-headline" id="Reciprocal_Best">Reciprocal Best</span></h2>
<p>After that alignment is completed, the <b>reciprocal best</b> alignment can be computed:
</p>
<pre>cd /data/genomes/dm6/trackData/GCF_000005575.2_AgamP3
export tDb=`grep "SEQ1_DIR=" DEF | sed -e 's#.*/##; s#.2bit##;'`
export qDb=`grep "SEQ2_DIR=" DEF | sed -e 's#.*/##; s#.2bit##;'`
export target2Bit=`grep "SEQ1_DIR=" DEF | sed -e 's/.*=//;'`
export targetSizes=`grep "SEQ1_LEN=" DEF | sed -e 's/.*=//;'`
export query2Bit=`grep "SEQ2_DIR=" DEF | sed -e 's/.*=//;'`
export querySizes=`grep "SEQ2_LEN=" DEF | sed -e 's/.*=//;'`
time (/data/scripts/doRecipBest.pl -buildDir=`pwd` -load \
  -workhorse=localhost -dbHost=localhost -skipDownload \
   -target2Bit=${target2Bit} -query2Bit=${query2Bit} \
    -targetSizes=${targetSizes} -querySizes=${querySizes} \
      -trackHub ${tDb} ${qDb}) &gt; rbest.log 2&gt;&amp;1 &amp;
</pre>
<p>This process does not have any <b>parasol batch</b> procedures.  The procedure only
does transformations on some of the result files computed during the first alignment
procedure.  Since this is not a parallel procedure, it takes a bit of time:
</p>
<pre>grep -w step rbest.log
HgStepManager: executing from step 'recipBest' through step 'cleanup'.
HgStepManager: executing step 'recipBest' Fri Apr  6 05:24:27 2018.
HgStepManager: executing step 'download' Fri Apr  6 05:55:38 2018.
HgStepManager: executing step 'load' Fri Apr  6 05:55:38 2018.
HgStepManager: executing step 'cleanup' Fri Apr  6 05:55:47 2018.
</pre>
<p>When completed, this has a <b>featureBits</b> measurement also:
</p>
<pre>cat fb.dm6.chainRBest.GCF_000005575.2_AgamP3.txt 
15316412 bases of 143726002 (10.657%) in intersection
</pre>
<h2><span class="mw-headline" id="Swap">Swap</span></h2>
<p>Now that one chain is finished you can swap the reverse direction, note the "swap" and "swapDir" arguments to doBlastzChainNet.pl:
</p>
<pre>mkdir -p /data/genomes/oviAri4/trackData/openstack.lastzHg38.2018-04-26/
cd /data/genomes/oviAri4/trackData/openstack.lastzHg38.2018-04-26/

time (/data/scripts/doBlastzChainNet.pl \
   /data/genomes/hg38/trackData/openstack.lastzOviAri.2018-04-26/DEF \
   -swap -swapDir=`pwd` -verbose=2 -noDbNameCheck -workhorse=localhost \
   -bigClusterHub=localhost -skipDownload -dbHost=localhost \
   -smallClusterHub=localhost -trackHub -    fileServer=localhost \
   -syntenicNet) &gt; swap.log 2&gt;&amp;1 &amp;
</pre>
<h2><span class="mw-headline" id="Track_Hub_files">Track Hub files</span></h2>
<p>This procedure has constructed <b>big*</b> files that can be used to display
these tracks in a <a rel="nofollow" class="external text" href="http://genome.ucsc.edu/goldenPath/help/hgTrackHubHelp.html">track hub</a>
on the <b>UCSC genome browser</b>
</p>
<pre>ls axtChain/*.bb bigMaf/*.bb
axtChain/chainGCF_000005575.2_AgamP3.bb
axtChain/chainGCF_000005575.2_AgamP3Link.bb
axtChain/chainRBestGCF_000005575.2_AgamP3.bb
axtChain/chainRBestGCF_000005575.2_AgamP3Link.bb
axtChain/chainSynGCF_000005575.2_AgamP3.bb
axtChain/chainSynGCF_000005575.2_AgamP3Link.bb
bigMaf/dm6.GCF_000005575.2_AgamP3.net.bb
bigMaf/dm6.GCF_000005575.2_AgamP3.net.summary.bb
bigMaf/dm6.GCF_000005575.2_AgamP3.rbestNet.bb
bigMaf/dm6.GCF_000005575.2_AgamP3.rbestNet.summary.bb
bigMaf/dm6.GCF_000005575.2_AgamP3.synNet.bb
bigMaf/dm6.GCF_000005575.2_AgamP3.synNet.summary.bb
</pre>
<p><b>(TBD: show structure of trackDb.txt track hub specifications)</b>
</p>
<h2><span class="mw-headline" id="How_does_this_process_work">How does this process work</span></h2>
<p>The <b>doBlastzChainNet.pl</b> script performs the processing in distinct <b>steps</b>.  Each <b>step</b> is
almost always performed with a C-shell or bash shell script.  Therefore, if there is a problem in
any <b>step</b>, the commands performing the <b>step</b> can be dissected from the script in operation,
the problem identified and fixed, and the <b>step</b> completed manually by running the rest of the
commands in that script.  Once a step has been completed, the process can continue with the next
step using the argument <b>-continue=nextStepName</b>.  Check the usage message from the <b>doBlastzChainNet.pl</b>
script to see a listing of the <b>steps</b> and their sequence.  Specifically:
</p>
<pre>partition, blastz, cat, chainRun, chainMerge, net, load, download, cleanup, syntenicNet
</pre>
<p>In this example, the various scripts are:
</p>
<pre>-rwxrwxr-x. 1 1914 Apr  6 04:50 run.blastz/doPartition.bash
-rw-rw-r--. 1 2713 Apr  6 04:50 run.blastz/xdir.sh
-rwxrwxr-x. 1  606 Apr  6 04:50 run.blastz/doClusterRun.csh
-rwxrwxr-x. 1  802 Apr  6 05:13 run.cat/doCatRun.csh
-rwxrwxr-x. 1   72 Apr  6 05:13 run.cat/cat.csh
-rwxrwxr-x. 1  412 Apr  6 05:14 axtChain/run/chain.csh
-rwxrwxr-x. 1  700 Apr  6 05:14 axtChain/run/doChainRun.csh
-rwxrwxr-x. 1 3112 Apr  6 05:15 axtChain/netChains.csh
-rwxrwxr-x. 1 2162 Apr  6 05:17 axtChain/loadUp.csh
-rwxrwxr-x. 1 1479 Apr  6 05:17 cleanUp.csh
-rwxrwxr-x. 1 4507 Apr  6 05:17 axtChain/netSynteny.csh
-rwxrwxr-x. 1 6321 Apr  6 05:24 axtChain/doRecipBest.csh
-rwxrwxr-x. 1 1974 Apr  6 05:55 axtChain/loadRBest.csh
-rwxrwxr-x. 1  583 Apr  6 05:55 rBestCleanUp.bash
</pre>
<!-- 
NewPP limit report
Cached time: 20180814025333
Cache expiry: 86400
Dynamic content: false
CPU time usage: 0.081 seconds
Real time usage: 0.084 seconds
Preprocessor visited node count: 94/1000000
Preprocessor generated node count: 144/1000000
Post‐expand include size: 0/2097152 bytes
Template argument size: 0/2097152 bytes
Highest expansion depth: 2/40
Expensive parser function count: 0/100
-->
<!--
Transclusion expansion time report (%,ms,calls,template)
100.00%    0.000      1 -total
-->

<!-- Saved in parser cache with key wikidb-mw1_:pcache:idhash:9521-0!*!0!!en!5!* and timestamp 20180814025333 and revision id 24830
 -->
</div><div class="printfooter">
Retrieved from "<a dir="ltr" href="http://genomewiki.ucsc.edu/index.php?title=DoBlastzChainNet.pl&amp;oldid=24830">http://genomewiki.ucsc.edu/index.php?title=DoBlastzChainNet.pl&amp;oldid=24830</a>"</div>
					<div id="catlinks" class="catlinks" data-mw="interface"><div id="mw-normal-catlinks" class="mw-normal-catlinks"><a href="/index.php/Special:Categories" title="Special:Categories">Categories</a>: <ul><li><a href="/index.php/Category:Cluster_FAQ" title="Category:Cluster FAQ">Cluster FAQ</a></li><li><a href="/index.php/Category:Technical_FAQ" title="Category:Technical FAQ">Technical FAQ</a></li></ul></div></div>					<!-- end content -->
										<div class="visualClear"></div>
				</div>
			</div>
					</div>
		<div id="column-one">
			<h2>Navigation menu</h2>
					<div id="p-cactions" class="portlet" role="navigation">
			<h3>Views</h3>

			<div class="pBody">
				<ul>
				<li id="ca-nstab-main" class="selected"><a href="/index.php/DoBlastzChainNet.pl" title="View the content page [c]" accesskey="c">Page</a></li>
				<li id="ca-talk" class="new"><a href="/index.php?title=Talk:DoBlastzChainNet.pl&amp;action=edit&amp;redlink=1" rel="discussion" title="Discussion about the content page [t]" accesskey="t">Discussion</a></li>
				<li id="ca-viewsource"><a href="/index.php?title=DoBlastzChainNet.pl&amp;action=edit" title="This page is protected.&#10;You can view its source [e]" accesskey="e">View source</a></li>
				<li id="ca-history"><a href="/index.php?title=DoBlastzChainNet.pl&amp;action=history" title="Past revisions of this page [h]" accesskey="h">History</a></li>
				</ul>
							</div>
		</div>
				<div class="portlet" id="p-personal" role="navigation">
				<h3>Personal tools</h3>

				<div class="pBody">
					<ul>
													<li id="pt-login"><a href="/index.php?title=Special:UserLogin&amp;returnto=DoBlastzChainNet.pl" title="You are encouraged to log in; however, it is not mandatory [o]" accesskey="o">Log in</a></li>
													<li id="pt-createaccount"><a href="/index.php/Special:RequestAccount" title="You are encouraged to create an account and log in; however, it is not mandatory">Request account</a></li>
											</ul>
				</div>
			</div>
			<div class="portlet" id="p-logo" role="banner">
				<a href="/index.php/Main_Page" class="mw-wiki-logo" title="Visit the main page"></a>
			</div>
				<div class="generated-sidebar portlet" id="p-navigation" role="navigation">
		<h3>Navigation</h3>
		<div class="pBody">
							<ul>
											<li id="n-mainpage"><a href="/index.php/Main_Page" title="Visit the main page [z]" accesskey="z">Main Page</a></li>
											<li id="n-help"><a href="https://www.mediawiki.org/wiki/Special:MyLanguage/Help:Contents" title="The place to find out">Help</a></li>
											<li id="n-Categories"><a href="/index.php/Special:Categories">Categories</a></li>
											<li id="n-New-Pages"><a href="/index.php/Special:NewPages">New Pages</a></li>
											<li id="n-recentchanges"><a href="/index.php/Special:RecentChanges" title="A list of recent changes in the wiki [r]" accesskey="r">Recent changes</a></li>
											<li id="n-User-Listing"><a href="/index.php/Special:ListUsers">User Listing</a></li>
											<li id="n-My-Preferences"><a href="/index.php/Special:Preferences">My Preferences</a></li>
									</ul>
					</div>
		</div>
		<div class="generated-sidebar portlet" id="p-related_sites" role="navigation">
		<h3>related sites</h3>
		<div class="pBody">
							<ul>
											<li id="n-Science-And-Justice"><a href="http://www2.ucsc.edu/scienceandjustice/" rel="nofollow">Science And Justice</a></li>
									</ul>
					</div>
		</div>
		<div class="generated-sidebar portlet" id="p-hosted_projects" role="navigation">
		<h3>hosted projects</h3>
		<div class="pBody">
							<ul>
											<li id="n-Encode-Project"><a href="/index.php/ENCODE_Project_at_UCSC">Encode Project</a></li>
											<li id="n-Opsin-Evolution"><a href="/index.php/Opsin_evolution:_update_blog">Opsin Evolution</a></li>
									</ul>
					</div>
		</div>
			<div id="p-search" class="portlet" role="search">
			<h3><label for="searchInput">Search</label></h3>

			<div id="searchBody" class="pBody">
				<form action="/index.php" id="searchform">
					<input type="hidden" name="title" value="Special:Search"/>
					<input type="search" name="search" placeholder="Search genomewiki" title="Search genomewiki [f]" accesskey="f" id="searchInput"/>
					<input type="submit" name="go" value="Go" title="Go to a page with this exact name if it exists" id="searchGoButton" class="searchButton"/>&#160;
						<input type="submit" name="fulltext" value="Search" title="Search the pages for this text" id="mw-searchButton" class="searchButton"/>
				</form>

							</div>
		</div>
			<div class="portlet" id="p-tb" role="navigation">
			<h3>Tools</h3>

			<div class="pBody">
				<ul>
											<li id="t-whatlinkshere"><a href="/index.php/Special:WhatLinksHere/DoBlastzChainNet.pl" title="A list of all wiki pages that link here [j]" accesskey="j">What links here</a></li>
											<li id="t-recentchangeslinked"><a href="/index.php/Special:RecentChangesLinked/DoBlastzChainNet.pl" rel="nofollow" title="Recent changes in pages linked from this page [k]" accesskey="k">Related changes</a></li>
											<li id="t-specialpages"><a href="/index.php/Special:SpecialPages" title="A list of all special pages [q]" accesskey="q">Special pages</a></li>
											<li id="t-print"><a href="/index.php?title=DoBlastzChainNet.pl&amp;printable=yes" rel="alternate" title="Printable version of this page [p]" accesskey="p">Printable version</a></li>
											<li id="t-permalink"><a href="/index.php?title=DoBlastzChainNet.pl&amp;oldid=24830" title="Permanent link to this revision of the page">Permanent link</a></li>
											<li id="t-info"><a href="/index.php?title=DoBlastzChainNet.pl&amp;action=info" title="More information about this page">Page information</a></li>
									</ul>
							</div>
		</div>
			</div><!-- end of the left (by default at least) column -->
		<div class="visualClear"></div>
					<div id="footer" role="contentinfo">
						<div id="f-poweredbyico">
									<a href="//www.mediawiki.org/"><img src="/resources/assets/poweredby_mediawiki_88x31.png" alt="Powered by MediaWiki" srcset="/resources/assets/poweredby_mediawiki_132x47.png 1.5x, /resources/assets/poweredby_mediawiki_176x62.png 2x" width="88" height="31"/></a>
							</div>
					<ul id="f-list">
									<li id="lastmod"> This page was last edited on 12 June 2018, at 17:23.</li>
									<li id="privacy"><a href="/index.php/Genomewiki:Privacy_policy" title="Genomewiki:Privacy policy">Privacy policy</a></li>
									<li id="about"><a href="/index.php/Genomewiki:About" title="Genomewiki:About">About genomewiki</a></li>
									<li id="disclaimer"><a href="/index.php/Genomewiki:General_disclaimer" title="Genomewiki:General disclaimer">Disclaimers</a></li>
							</ul>
		</div>
		</div>
		<script>(window.RLQ=window.RLQ||[]).push(function(){mw.config.set({"wgPageParseReport":{"limitreport":{"cputime":"0.081","walltime":"0.084","ppvisitednodes":{"value":94,"limit":1000000},"ppgeneratednodes":{"value":144,"limit":1000000},"postexpandincludesize":{"value":0,"limit":2097152},"templateargumentsize":{"value":0,"limit":2097152},"expansiondepth":{"value":2,"limit":40},"expensivefunctioncount":{"value":0,"limit":100},"timingprofile":["100.00%    0.000      1 -total"]},"cachereport":{"timestamp":"20180814025333","ttl":86400,"transientcontent":false}}});});</script><script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-4289047-1', 'auto');
  ga('set', 'anonymizeIp', true);
  ga('send', 'pageview');

</script>
<script type="text/javascript" src="https://analytics.example.com/tracking.js"></script>
<script>(window.RLQ=window.RLQ||[]).push(function(){mw.config.set({"wgBackendResponseTime":275});});</script></body></html>
