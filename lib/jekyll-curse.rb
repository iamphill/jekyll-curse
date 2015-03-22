require 'yaml'

module Jekyll
  class CurseWords < Jekyll::Generator
    @@not_allowed_extensions = [
      '.scss',
      '.less',
      '.xml',
      '.js',
      '.coffee'
    ]

    @@replace_chars = ['*', '$', '%', '!', '#', '&']

    def generate(site)
      # Load up the yaml file containing all the curse words
      load_words

      # Remove curse words in all pages
      site.pages.each do |page|
        not_allowed = page_not_allowed(page.name)

        page.content = remove_curse_word(page.content) if !not_allowed
      end

      # Remove curse words in all pots
      site.posts.each do |post|
        not_allowed = page_not_allowed(post.name)

        post.content = remove_curse_word(post.content) if !not_allowed
      end
    end

    # Private: Loads the YAML file with the curse words
    def load_words
      @@curse_words = YAML::load_file(File.join(__dir__, 'curse-words.yml'))['words']
    end

    # Private: Checks if the page should be checked based on not allowed extensions
    #
    # name - The name of the page
    #
    # Returns true/false on whether the page is allowed
    def page_not_allowed(name)
      @@not_allowed_extensions.any? do |word|
        name.include?(word)
      end
    end

    # Private: Removes any of the curse words from the content
    #
    # content - The page content
    #
    # Returns the content minus any curse words
    def remove_curse_word(content)
      # Search for any of the curse words
      @@curse_words.each do |word|
        regex = /#{word}/i
        if found = content.match(regex)
          # Mask the curse word
          content = content.gsub!("#{found}", mask_curse_word(found.to_s))
          puts content
        end
      end

      content
    end

    # Private: Masks the curse word found
    #
    # word - Found curse word
    #
    # Returns the masked curse word
    def mask_curse_word(word)
      "#{word[0]}#{replace_letters(word[1..-2])}#{word[-1]}"
    end

    # Private: Replace letters with random characters
    #
    # letter - Letters to replace
    #
    # Returns the letters replace with chars
    def replace_letters(letters)
      l = letters.split('').map do |letter|
        @@replace_chars.sample
      end

      l.join('')
    end
  end
end
