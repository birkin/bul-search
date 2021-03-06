Brown implementation of Blacklight.

## Installation

Read the [Blacklight Quickstart](https://github.com/projectblacklight/blacklight/wiki/Quickstart)
to become familar with the project.  You might want to follow the steps locally
and install a default Blacklight instance as a test project.

To install the Brown Blacklight code locally:

 * verify that you have the dependencies listed in the Quickstart.
 * check out the code.
 * cd into the code and run `bundle install`.
 * `rake db:create db:migrate` to create the database.
 * `rake jetty:clean` to download Jetty and Solr.
 * `rake jetty:start` to start Jetty and Solr.  Note the Solr port.  This needs
 to match the solr port in `config/jetty.yml`. Also see below about setting up
 your environment using a `.env` file.  The SOLR_URL can be set there.
 * `rake solr:marc:index MARC_FILE=data/bul_sample.mrc` to index sample
 Brown records. Although this is a quick way to load data into Solr keep in mind that **this is not the way** we import data in production and will give you a different set of fields in Solr from that we really use. See the Sample Records section below to import data using the same mechanism as we do in production.
 * `rails server` to start rails in development mode
 * If all goes correctly: visit the catalog at http://localhost:3000/catalog.
 * A sample search of `gender` will return results from the sample set of MARC
 records.

## schema.rb
By default the development environment uses MySQL so that it matches with what
we use in production. If you switch to SQLite for development (by updating
`config/database.yml`) beware that you might get a slightly different
`schema.rb` file after running `rake db:migrate`. You should discard those
changes  with `git checkout -- schema.rb` so that you don't accidentally
commit them to the repository.

## Sample Records
In production we use `traject` to import data into Solr. You can mimic this setup by using `traject` in your local environment as follows:

```
# Get the code for our `traject` project
git clone git@github.com:Brown-University-Library/bul-traject.git
cd bul-traject

# Import a sample file
traject -c config.rb -u http://localhost:8081/solr/blacklight-core /path/to/marc/file/bul_sample.mrc

# Commit the data to Solr
curl "http://localhost:8081/solr/blacklight-core/update?commit=true"

# Check it out
curl "http://localhost:8081/solr/blacklight-core/select?fq=*%3A*&wt=json&indent=true"
```

You can pass the `--debug-mode` flag to Traject if you just want to see what will be imported but not import it to Solr.

## Without running a local Solr index.
If you want to run the Blacklight web application but not build a local Solr index, set SOLR_URL in your `.env` file to `http://server.name.brown.edu:8081/solr`.  This will allow you to search the remote index.  You will need to be on the Brown network (in the SciLi?) or connected via VPN to connect to this index.

## Environment setup
For development the [dotenv](https://github.com/bkeepers/dotenv) gem has been added.  Local settings can be set in the a `.env` file.  `sample-env` is included. Copy it to `.env` and adjust the values.

An additional rails environment has been created called `devbox`.  I created this because I want to run Rails on `dblightcit` in development mode for now.  I also have had trouble installing the `debugger` gem on the server.  So creating another environment for local gemsets seems to be a route to take.  You can follow this pattern as well or just use the development Rails environment locally.

## Article (summon)
If you wish to include articles in the results you will need to set the
SUMMON_ID and SUMMON_KEY

## Repository (bdr)
If you wish to include repository items in your results you will need to
set the BDR_SEARCH_URL to a SOLR compatible endpoint

For development you can use the dev public search api endpoint
http://server.name.brown.edu/api/search/

For Repository links You will need to set BDR_ITEM_URL.  No trailing slash.
//server.name.brown.edu/studio/item


## Indexing data (adding documents)
We have customized `config/SolrMarc/index.properties` to use a record id of `id = 907a[1-8], first`.  This is because Brown's library system stores the unique bibliographic record number in the 907 field.

This means that the sample MARC records distributed with Blacklight won't load with the default schema.

A sample set of 31 MARC records are included in the data/ directory.

These records can be indexed with:

 * `rake solr:marc:index MARC_FILE=data/bul_sample.mrc`

A sample search of `atomic` will return results.

## Solr management
Two shell scripts are included in data/ to assist with managing a local Solr index.  `./data/clear_index.sh` will clear your current Solr index.  It uses the environment variables in `.env` for the Solr url.  `./data/solr_commit.sh` will call commit on your index to ensure that any posted documents are added to the index.  Use with caution if you are working with a real Solr index.


## Bento Box
The working name for this app/project is `easySearch`.

Locally the Bento Box is available at: `http://localhost:3000/easy/`

At present, the Bento Box queries Summon and the local Solr index for data.

The model code is in `app/models/easy.rb` and the JavaScript for now is in `app/views/easy/home.html.erb`.

## Fort stats

 * All formats `facet.field=format&fact.sort=count&facet=true&rows=0&facet.limit=50&facet.mincount=1`
