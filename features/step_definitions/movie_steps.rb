# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
  Movie.create(movie)
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  assert page.body.index(e1) < page.body.index(e2)
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  ratings = rating_list.split(%r{,\s*})
  ratings.each do |rating|
    if uncheck.nil?
      check('ratings_' + rating)
    else
      uncheck('ratings_' + rating)
    end
  end
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
end

Then /^(?:|I )should see these movies (.*)/ do |text|
  titles = text.split(/"([^"]*)"\s*/).reject {|s| s.empty?}
  titles.each do |title|
    if page.respond_to? :should
      page.should have_content(title)
    else
      assert page.has_content?(title)
    end
  end
  click_button('ratings_submit')
end

Then /^(?:|I )should not see these movies (.*)/ do |text|
  titles = text.split(/"([^"]*)"\s*/).reject {|s| s.empty?}
  titles.each do |title|
    if page.respond_to? :should
      page.should have_no_content(title)
    else
      assert page.has_no_content?(title)
    end
  end
end

Given /I check the all ratings/ do
  Movie.all_ratings.each do |rating|
    check('ratings_' + rating)
  end
end

Then /I should see all of the movies/ do
  dbMovieCnt = Movie.find(:all).length
  uiMovieCnt = page.body.scan(/(<tr>)/).size-1
  assert dbMovieCnt==uiMovieCnt
end
