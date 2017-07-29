class Admin::DiscountCodesController < Admin::AdminBaseController

  def new
    @selected_left_navi_link = "listing_categories"
    @code = DiscountCode.new
  end

  def create
    @selected_left_navi_link = "listing_categories"
    @code = DiscountCode.new(code_params)

    if @code.save
      redirect_to discount_codes_admin_community_path(@current_community, sort: "created_date", direction: "desc")
    else
      flash[:error] = "Discount code saving failed"
      render :action => :new
    end
  end

  def code_active
    @code = DiscountCode.find(params[:id])
    respond_to do |format|
      format.js { 
        flash.now[:notice] = "Here is my flash notice" 
        if @code.update_attributes(:active => params[:active])
          redirect_to discount_codes_admin_community_path(@current_community, sort: "created_date", direction: "desc")
        else
          flash[:error] = "Discount code update failed"
          redirect_to discount_codes_admin_community_path(@current_community, sort: "created_date", direction: "desc")
        end
      }
    end
  end

  def edit
    @selected_left_navi_link = "listing_categories"
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    shapes = get_shapes
    selected_shape_ids = CategoryListingShape.where(category_id: @category.id).map(&:listing_shape_id)
    render locals: { shapes: shapes, selected_shape_ids: selected_shape_ids }
  end

  def update
    @selected_left_navi_link = "listing_categories"
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    shapes = get_shapes
    selected_shape_ids = shape_ids_from_params(params)

    if @category.update_attributes(category_params)
      update_category_listing_shapes(selected_shape_ids, @category)
      redirect_to admin_categories_path
    else
      flash[:error] = "Category saving failed"
      render :action => :edit, locals: { shapes: shapes, selected_shape_ids: selected_shape_ids }
    end
  end

  # Remove form
  def remove
    @selected_left_navi_link = "listing_categories"
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    @possible_merge_targets = Admin::CategoryService.merge_targets_for(@current_community.categories, @category)
  end

  # Remove action
  def destroy
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    @category.destroy
    redirect_to admin_categories_path
  end

  def destroy_and_move
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    new_category = @current_community.categories.find_by_url_or_id(params[:new_category])

    if new_category
      # Move listings
      @category.own_and_subcategory_listings.update_all(:category_id => new_category.id)

      # Move custom fields
      Admin::CategoryService.move_custom_fields!(@category, new_category)
    end

    @category.destroy

    redirect_to admin_categories_path
  end

  private

  def code_params
    params.require(:discount_code).permit(:code)
  end

end
