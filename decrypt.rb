# extract from https://github.com/rapid7/metasploit-framework/blob/master/modules/post/multi/gather/lastpass_creds.rb

require 'openssl'
require 'uri'
require 'rex'

# Lastpass Login Email Address
key = 'your-email@address.org'

# Password from store
pass = '!2gMG7wfsfPxMDw136HKfDg==|dOSL5wZ6Nx2vXckq52J91M=='

def decrypt_data(key, encrypted_data)

    if encrypted_data.include?("|") # Use CBC
      decipher = OpenSSL::Cipher.new("AES-256-CBC")
      decipher.iv = Rex::Text.decode_base64(encrypted_data[1, 24]) # Discard ! and |
      encrypted_data = encrypted_data[26..-1] # Take only the data part
    else # Use ECB
      decipher = OpenSSL::Cipher.new("AES-256-ECB")
    end

    begin
      decipher.decrypt
      decipher.key = key
      decrypted_data = decipher.update(Rex::Text.decode_base64(encrypted_data)) + decipher.final
    rescue OpenSSL::Cipher::CipherError => e
      print "-- Data could not be decrypted. #{e.message} --"
    end

    decrypted_data
end

pass = URI.unescape(pass)
key = [OpenSSL::Digest::SHA256.hexdigest(key)].pack "H*"

printf decrypt_data(key, pass) + "\n"
