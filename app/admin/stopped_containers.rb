ActiveAdmin.register_page 'Stopped Containers' do
  content do
    records = Morph::DockerUtils.stopped_containers.map do |container|
      run = Morph::Runner.run_for_container(container)
      info = container.json
      record = {
        container_id: info['Id'][0..11],
        exit_code: info['State']['ExitCode'],
        finished_at: Time.parse(info['State']['FinishedAt']),
        oom_killed: info['State']['OOMKilled'] ? 'yes' : 'no'
      }
      if run
        record[:run_id] = run.id
        record[:scraper_name] = run.scraper.full_name if run.scraper
        record[:running] = run.running? ? 'yes' : 'no'
        record[:auto] = run.auto? ? 'yes' : 'no'
      end
      record
    end

    table do
      thead do
        tr do
          th 'Container ID'
          th 'Exit code'
          th 'Finished'
          th 'OOM Killed'
          th 'Run ID'
          th 'Scraper name'
          th 'Running'
          th 'Auto'
        end
      end

      tbody do
        records.each do |record|
          tr do
            td record[:container_id]
            td record[:exit_code]
            td time_ago_in_words(record[:finished_at]) + ' ago'
            td record[:oom_killed]
            td do
              if record[:run_id]
                link_to record[:run_id], admin_run_path(id: record[:run_id])
              end
            end
            td do
              if record[:scraper_name]
                link_to record[:scraper_name], scraper_path(id: record[:scraper_name])
              end
            end
            td record[:running]
            td record[:auto]
          end
        end
      end
    end
  end
end
