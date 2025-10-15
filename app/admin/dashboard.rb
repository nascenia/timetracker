ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  page_action :toggle_face_recognition, method: :post do
    enable = User.where(face_recognition_required: false).exists?
    User.update_all(face_recognition_required: enable)
    redirect_to admin_dashboard_path, notice: "Face recognition has been #{enable ? 'enabled' : 'disabled'} for all users."
  end

  content title: proc{ I18n.t("active_admin.dashboard") } do
    panel "Face Recognition" do
      div do
        all_enabled = !User.where(face_recognition_required: false).exists?
        para "Face recognition is currently #{all_enabled ? 'enabled' : 'disabled'} for all users."
        div style: "margin-top: 10px;" do
          a :href => toggle_face_recognition_admin_dashboard_path, "data-method" => :post, :class => "button" do
            all_enabled ? "Disable Face Recognition for All" : "Enable Face Recognition for All"
          end
        end
      end
    end

    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
