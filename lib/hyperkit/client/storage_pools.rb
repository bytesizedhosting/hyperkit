require 'active_support/core_ext/hash/except'

module Hyperkit

  class Client

    module StoragePools

      def storage_pools
        response = get(storage_pools_path)
        response.metadata.map { |path| path.split('/').last }
      end

      def create_storage_pool(name, options={})
        opts = options.merge(name: name)
        opts[:config] = stringify_hash(opts[:config]) if opts[:config]
        post(storage_pools_path, opts).metadata
      end

      def storage_pool(name)
        get(storage_pool_path(name)).metadata
      end

      def update_storage_pool(name, options={})
        opts = options.except(:name)
        opts[:config] = stringify_hash(opts[:config]) if opts[:config]
        put(storage_pool_path(name), opts).metadata
      end

      def rename_storage_pool(old_name, new_name)
        post(storage_pool_path(old_name), { name: new_name }).metadata
      end

      def delete_storage_pool(name)
        delete(storage_pool_path(name)).metadata
      end

      def volumes(storage_pool)
        response = get volumes_path(storage_pool)
        response.metadata.map { |path| path.split('/').last }
      end

      def volume_type(storage_pool, type)
        response = get(volume_type_path(storage_pool, type))
        response.metadata.map { |path| path.split('/').last }
      end

      def volume(storage_pool, type, volume)
        get(volume_path(storage_pool, type, volume)).metadata
      end

      def create_volume(storage_pool, volume, options={})
        post(new_volume_path(storage_pool), options.reverse_merge(name: volume))
      end

      def delete_volume(storage_pool, type, volume)
        delete(volume_path(storage_pool, type, volume)).metadata
      end

      def rename_volume(storage_pool, type, volume, config={})
        post(volume_path(storage_pool, type, volume), config)
      end

      def update_volume(storage_pool, type, volume, config={})
        old_config = volume(storage_pool, type, volume).to_h
        old_config[:config] = old_config[:config].merge(config)
        update_config = old_config

        put(volume_path(storage_pool, type, volume), update_config)
      end

      def create_volume_snapshot(storage_pool, volume_name, snapshot_name)
        post( new_snapshot_volume_path(storage_pool, volume_name), {name: snapshot_name})
      end

      private

      #Volumes
      def volumes_path(name)
        File.join(storage_pool_path(name), "volumes")
      end

      def volume_type_path(storage_pool, type)
        File.join(volumes_path(storage_pool), type)
      end

      def volume_path(storage_pool, type, volume)
        File.join(volumes_path(storage_pool), type, volume)
      end

      def new_volume_path(storage_pool)
        File.join(storage_pools_path, storage_pool, "volumes")
      end

      def new_snapshot_volume_path(storage_pool, volume_name, volume_type = "custom")
        File.join(storage_pools_path, storage_pool, "volumes", volume_type, volume_name, "snapshots")
      end

      #Storage pools
      def storage_pools_path
        "/1.0/storage-pools"
      end

      def storage_pool_path(name)
        File.join(storage_pools_path, name)
      end

    end
  end

end
