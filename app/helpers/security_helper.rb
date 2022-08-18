# Copyright 2011-2022, The Trustees of Indiana University and Northwestern
#   University.  Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
#   under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#   CONDITIONS OF ANY KIND, either express or implied. See the License for the
#   specific language governing permissions and limitations under the License.
# ---  END LICENSE_HEADER BLOCK  ---

module SecurityHelper
  def add_stream_cookies(stream_info)
    SecurityHandler.secure_cookies(target: stream_info[:id], request_host: request.server_name).each_pair do |name, value|
      cookies[name] = value
    end
  end

  def secure_streams(stream_info, media_object_id)
    begin
      if MediaObject.find(media_object_id).visibility == 'public'
        add_stream_url(stream_info)
      else
        if Avalon::Configuration.controlled_digital_lending_enabled? && Checkout.checked_out_to_user(media_object_id, current_user.id).empty?
          raise StreamToken::Unauthorized
        else
          add_stream_url(stream_info)
        end
      end
    rescue StreamToken::Unauthorized
    end
    stream_info
  end

  def add_stream_url(stream_info)
    add_stream_cookies(id: stream_info[:id])
    [:stream_hls].each do |protocol|
      stream_info[protocol].each do |quality|
        quality[:url] = SecurityHandler.secure_url(quality[:url], session: session, target: stream_info[:id], protocol: protocol)
      end
    end
  end
end
