module HttpUtilities
  module Proxies
    class ProxySeeder
      attr_accessor :protocols, :proxy_types, :categories

      def initialize
        self.protocols      =   ['http', 'socks5']
        self.proxy_types    =   ['public', 'shared', 'private']
        self.categories     =   ['L1', 'L2', 'L3', 'unspecified']
      end

      def seed
        import_proxies
      end

      def import_proxies
        proxy_data = parse_proxies

        proxy_data.each do |protocol, types|
          types.each do |type, categories|
            categories.each do |category, proxies|
              bulk_import_proxies(proxies, protocol, type, category)
            end
          end        
        end if (proxy_data && !proxy_data.empty?)
      end

      def bulk_import_proxies(proxy_list, protocol, proxy_type, category)        
        columns     =   [:host, :port, :protocol, :proxy_type, :category]
        category    =   (category && !category.eql?('unspecified')) ? category : nil

        begin
          proxy_list.slice!(0..1000).each do |proxy|
            host              =   proxy[:host]
            port              =   proxy[:port]
            
            proxy             =   ::Proxy.where(host: host, port: port).first || ::Proxy.new
            proxy.host        =   host
            proxy.port        =   port
            proxy.protocol    =   protocol
            proxy.proxy_type  =   proxy_type
            proxy.category    =   category
            proxy.save
          end
          
        end while (proxy_list && proxy_list.any?)
      end

      def parse_proxies
        proxies = {}

        self.protocols.each do |protocol|
          proxies[protocol] = {}

          self.proxy_types.each do |proxy_type|
            proxies[protocol][proxy_type] = {}
            proxies[protocol][proxy_type]['unspecified'] = []

            if (protocol.eql?("http"))
              self.categories.each do |category|
                proxies[protocol][proxy_type][category] = get_proxies_from_files("#{get_seed_root}#{protocol}/#{proxy_type}/#{category}/*.txt")
              end
            end
            
            proxies[protocol][proxy_type]['unspecified'] = proxies[protocol][proxy_type]['unspecified'] + get_proxies_from_files("#{get_seed_root}#{protocol}/#{proxy_type}/*.txt")
          end
        end

        return proxies
      end

      def get_proxies_from_files(pattern)
        proxies = []
        file_paths = Dir.glob(pattern)

        file_paths.each do |file_path|
          proxy_rows = []
          File.open(file_path, 'r') {|f| proxy_rows = f.readlines("\n") }

          proxy_rows.each do |row|
            host, port  =   nil
            
            parts       =   row.include?(":") ? row.split(":") : nil
            
            if (parts && parts.any? && parts.size >= 2)
              host        =   parts.first
              port        =   parts.second.to_i
            end
            
            proxies << {:host => host, :port => port} if (host && port)
          end
        end

        return proxies
      end
      
      def get_seed_root
        rails_seed_root   =   defined?(Rails) ? "#{Rails.root}/db/seed_data/proxies/" : nil
        gem_seed_root     =   File.join(File.dirname(__FILE__), "../../generators/templates/seed_data/proxies/")
        
        return (rails_seed_root && File.exists?(rails_seed_root)) ? rails_seed_root : gem_seed_root
      end

    end
  end
end