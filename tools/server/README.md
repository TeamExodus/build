Tools for gerrit and merges

All tools need an

export GERRIT_USER=Your_Gerrit_Username


gerritadd:
gerritadd is only working local on the build server and adds the named git repo to gerrit
usage:gerritadd {reponame}

gerritflushcache:
after adding a new repo, syncing repos, or removing a repo, the gerrit cache has to be flushed
this is done with this command

gerritsyncall:
gerritsyncall works only on the server and syncs all repos,eg if somebody pushed directly to server (he should diaf !)

mergeadd:
mergeadd adds a new repo to the folders to be merged, and also the remote for cm
all repos are located in ~/merges
usage: mergeadd {reponame}

merge:
this command tries to merge all repos in the folder ~/merges
it will stop when a merge fails
TODO: maybe it would be a nice idea when we could get this to continue on the repo it stopped after user manually fixed the merging issue

private-merge:
nearly the same as merge, but it will merge all folders inside of ~/private-merges
there it will not merge cm/cm-12.1 but public/EXODUS-5.1 eg. frameworks_base -> private_frameworks_base

push:
a short command for git push to gerrit. it is used inside a repo folder (eg inside your exodus developement folder\frameworks\base
usage reponame branch (eg push private_frameworks_base refs/for/EXODUS-5.1)

init_all_merge_repos:
creates all currently needed init files based on the file list_of_current_merges_repos
usage: init_all_merge_repos path to list_of_current_merges_repos (eg init_all_merge_repos ~/tools/list_of_current_merges_repos )

