require "net/http"
require "base64"
require "json"

module Sideload
  module Github
    extend self

    GITHUB_V3 = URI("https://api.github.com")

    def credentials=(arr)
      @user, @pass = arr
    end

    def read(repo, path)
      sha = navigate_to(repo, path)
      return traverse(repo, sha)
    end

    def with(path, fname)
      raise RuntimeError.new("not implemented")
    end

    def write(full_path, target, content)
      raise RuntimeError.new("not implemented")
    end

    def delete(full_path, target)
      raise RuntimeError.new("not implemented")
    end

    private

    def traverse(repo, sha, path = [])
      return get_tree(repo, sha).reduce({}) do |acc, node|
        name = node["path"]
        case node["type"]
        when "blob"
          acc[(path + [name]).join("/")] = get_blob(node["url"])
        when "tree"
          acc.merge!(traverse(repo, node["sha"], path + [name]))
        end
        next acc
      end
    end

    def navigate_to(repo, path)
      return path.split("/").reduce("master") do |acc, folder|
        get_tree(repo, acc)&.detect { |e| e["type"] && e["path"] == folder }&.
          []("sha")
      end
    end

    def get_blob(url)
      cred!
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(@user, @pass) if @user
      response = http.request(request)
      if response.is_a?(Net::HTTPOK)
        return Base64.decode64(JSON.parse(response.body)&.[]("content"))
      else
        puts response, url
        return nil
      end
    end

    def get_tree(repo, folder)
      cred!
      uri = URI.join(GITHUB_V3, "/repos/#{repo}/git/trees/#{folder}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(@user, @pass) if @user
      response = http.request(request)
      if response.is_a?(Net::HTTPOK)
        return JSON.parse(response.body)&.[]("tree")
      else
        puts response, uri
        return nil
      end
    end
  end
end
