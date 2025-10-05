# vim-open

`vim-open` is an extensible plugin designed to make the built-in gf command a little smarter.


## What it does

### The `gf` mapping

By default, `gf` will assume whatever is under your cursor is a local file path, and try to open that path in
the current vim window. At its core, this plugin is just a way to let you add support for different types of
paths, URIs and identifiers to that command, so that you can also use the same binding to open other types of
things in whatever way makes sense for that thing.

By default, does the following:

| if your cursor is on ... | vim-open's `gf` mapping will...    |
|--------------------------|------------------------------------|
| an http(s) link          | ... open that link in your browser |
| anything else            | ... delegate to the default `gf`   |

Where this gets more interesting, is adding your own extensions. So for example, you might want to add support
for ticket IDs in your teams ticket tracking system (i.e. hitting `gf` on `CC-1234` would open the
corresponding ticket in a browser), or things that look like github repos (i.e. hitting `gf` on
`[sophiehicks1/vim-open]` would open this repo in github), or handles in your team's favorite IM client (so
that hitting it on `@sophie` would take you to your DM with me in slack or teams or discord). The
possibilities are endless!

### How it works:

`vim-open` is configured as a list of finders and a list of openers. When you invoke the `gf` binding, it
creates a context object representing all the state of the current context (e.g. the file type, the cursor
location, word under the cursor, etc.) and passes that context object to all the finders in turn. If/when one of
the finders is able to handle the information in that context, it will return a resource identifier (like a
file path, a URI, a link, etc.) which is then passed on to each of the openers in turn until one of them knows
how to open it.

So, as an example, if you wanted to add support for opening jpeg images in a photo viewing app, you could add
the following:

- a finder that recognized text that looks like a jpeg path (i.e. any paths that end in '.jpg' or '.jpeg'
  extensions) and returns an image identifier like "image:///path/to/image.jpg"
- an opener that recognizes links using the "image" protocol, and opens them in the default image app.

In practice, most finders return either a file path or a web link, both of which are handled out of the box,
so in reality, you usually only need to add openers when you want behavior other than "open this path in vim"
or "open this link in a browser"

## Configuration

There are two main extension points.

1. Use `gopher#add_finder()` to teach `vim-open` about a new pattern you want it to recognize
2. Use `gopher#add_opener()` to teach `vim-open` how to open a type of resource

### `gopher#add_finder(match_fn, extract_fn)`

`match_fn` is a function that accepts a context object, and returns boolean true if this finder can handle
the data currently under the cursor. Else it returns false.

`extract_fn` is a function that returns the resource identifier for the text under the cursor.

### `gopher#add_opener(can_handle_fn, handler)`

`can_handle_fn` is a function that accepts a string, and returns true if this opener can handle that string.

`handler` is a function that accepts a string and "opens" the resource represented by that string (whatever
that means).

## Examples:

Let's say you wanted to be able to use `gf` to be able to open `r/subreddit` addresses. You can do that with a
finder that recognizes those links and turns them into url like this:

```vimscript
let s:subreddit_pattern = 'r/\w\+'

" return true if the current WORD matches the subreddit pattern we're looking for
function! FindSubreddit(context)
  if a:context.WORD =~ 'r/\w\+'
    return v:true
  endif
  return v:false
endfunction

" turn that into a reddit URL, so that it's handled by the URL opener
function! ExtractSubreddit(context)
  return 'https://reddit.com/' . matchstr(a:context.WORD, 'r/\w\+')
endfunction
```

That would allow you to hit `gf` on any subreddit, in any file and have the right link open in your default
browser, which is awesome... but not perfect. Sometimes it makes sense for more complex finders to add
filetype specific support for links. For example, [this plugin](https://github.com/sophiehicks1/mdpp/blob/master/autoload/md/vimopen.vim)
adds support for all link types in markdown, so you can use `gf` with your cursor anywhere on any part of any
markdown link, and it will extract the address portion of the link and pass that through to all your
configured openers.

The problem with the subreddit example above is that it finds subreddit links in text okay, but it immediately
converts them to URLs. It'll mostly work, but even with both the above subreddit integration and the linke
markdown integration, the following link wouldn't work when your cursor was in the text portion of the link.

```
[link][1]

[1]: r/vim
```

Here's what would happen.

- The markdown finder would correctly recognize the markdown link format, extract the `r/vim` reference
  from the address, and pass that to the openers.
  * Since our subreddit integration only includes a finder, there's no _opener_ which knows how to open
    subreddit links on their own, so this fails and it moves on try the next thing.
- The subreddit finder would look at the cWORD (which is `[link][1]`), correctly identify that there's no
  subreddit link in there and fail to trigger.

So, here's a more complete subreddit integration which will work both for more complex generic finders like
the markdown one I linked to from [MDPP](https://github.com/sophiehicks1/MDPP) above, as well as when
subreddit links are found in plain text or elsewhere. (This is taken directly from my vim config) 

```vimscript
" If we find a subreddit match in <cWORD>, then our subreddit handlers can handle it so our finder returns
" true
function! FindSubreddit(context)
  if a:context.WORD =~ 'r/\w\+'
    return v:true
  endif
  return v:false
endfunction

" our extractor just returns the subreddit as an address (e.g. `'r/vim'`), because the opener is going to do
" the rest of the work
function! ExtractSubreddit(context)
  return matchstr(a:context.WORD, 'r/\w\+')
endfunction

" Here we register the subreddit finder. Remember, order matters because earlier finders get precedence. This
" one is pretty specific, so you want it after more generic finders like support for links in filetypes.
call gopher#add_finder(function('FindSubreddit'), function('ExtractSubreddit'))

" This part registers a subreddit _opener_, which knows how to convert any reddit address into a URL and hands
" that off to `gopher#open_url`

" return true if the address we're given is a subreddit string
function! IsSubreddit(str)
  return match(a:str, '^r/\w\+$') != -1
endfunction

" and open that as a link, using the `gopher#open_url` utility
function! SubredditLink(str)
  return gopher#open_url('https://reddit.com/' . a:str)
endfunction

call gopher#add_opener(function('IsSubreddit'), function('SubredditLink'))
```


