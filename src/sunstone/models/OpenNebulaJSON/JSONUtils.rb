# -------------------------------------------------------------------------- #
# Copyright 2002-2017, OpenNebula Project, OpenNebula Systems                #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

module OpenNebulaJSON

    require 'json'

    module JSONUtils
        def to_json
            begin
                JSON.pretty_generate self.to_hash
            rescue Exception => e
                OpenNebula::Error.new(e.message)
            end
        end

        def self.parse_json(json_str, root_element)
            begin
                hash = JSON.parse(json_str)
            rescue Exception => e
                return OpenNebula::Error.new(e.message)
            end

            if hash.has_key?(root_element)
                return hash[root_element]
            else
                return OpenNebula::Error.new("Error parsing JSON: Wrong resource type")
            end
        end

        def parse_json(json_str, root_element)
            JSONUtils.parse_json(json_str, root_element)
        end

        def parse_json_sym(json_str, root_element)
            begin
                parser = JSON.parser.new(json_str, {:symbolize_names => true})
                hash = parser.parse

                if hash.has_key?(root_element)
                    return hash[root_element]
                end

                Error.new("Error parsing JSON:\ root element not present")

            rescue => e
                Error.new(e.message)
            end
        end

        def template_to_str(attributes, indent=true)
             if indent
                 ind_enter="\n"
                 ind_tab='  '
             else
                 ind_enter=''
                 ind_tab=' '
             end

             str = attributes.collect do |key, value|
                 next if value.nil? || value.empty?
                 
                 str_line = ""

                 case value
                 when Array
                     value.each do |i|
                        next if i.nil? || i.empty?

                        case i
                        when Hash
                            str_line << key.to_s.upcase << "=[" << ind_enter
                            str_line << i.collect do |k, j|
                                str = ind_tab + k.to_s.upcase + "="
                                str += "\"#{j.to_s}\"" if j
                                str
                            end.compact.join(",\n")
                            str_line << "\n]\n"
                        else
                            str_line << key.to_s.upcase << "=\"#{i.to_s}\"\n"
                        end
                     end
                when Hash
                    str_line << key.to_s.upcase << "=[" << ind_enter

                    str_line << value.collect do |key3, value3|
                        str = ind_tab + key3.to_s.upcase + "="
                        str += "\"#{value3.to_s}\"" if value3
                        str
                    end.compact.join(",\n")

                    str_line << "\n]\n"

                else
                    str_line<<key.to_s.upcase << "=" << "\"#{value.to_s}\""
                end

                str_line
             end.compact.join("\n")

             str
         end
     end
end
