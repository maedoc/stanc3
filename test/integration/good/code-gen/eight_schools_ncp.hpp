
// Code generated by %%NAME%% %%VERSION%%
#include <stan/model/model_header.hpp>
namespace eight_schools_ncp_model_namespace {

using std::istream;
using std::string;
using std::stringstream;
using std::vector;
using stan::io::dump;
using stan::math::lgamma;
using stan::model::model_base_crtp;
using stan::model::rvalue;
using stan::model::assign;
using stan::model::cons_list;
using stan::model::index_uni;
using stan::model::index_max;
using stan::model::index_min;
using stan::model::index_min_max;
using stan::model::index_multi;
using stan::model::index_omni;
using stan::model::nil_index_list;
using namespace stan::math; 

static int current_statement__ = 0;
static const std::vector<string> locations_array__ = {" (found before start of program)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 8, column 2 to column 10)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 9, column 2 to column 20)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 10, column 2 to column 22)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 14, column 2 to column 16)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 16, column 4 to column 41)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 15, column 2 to line 16, column 41)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 20, column 2 to column 20)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 21, column 2 to column 21)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 22, column 2 to column 29)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 23, column 2 to column 27)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 2, column 2 to column 17)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 3, column 2 to column 12)",
                                                      " (in '/Users/xitrium/scm/stanc3/test/integration/good/code-gen/eight_schools_ncp.stan', line 4, column 2 to column 25)"};


class eight_schools_ncp_model : public model_base_crtp<eight_schools_ncp_model> {

 private:
  int pos__;
  int J;
  std::vector<double> y;
  std::vector<double> sigma;
 
 public:
  ~eight_schools_ncp_model() { }
  
  std::string model_name() const { return "eight_schools_ncp_model"; }
  
  eight_schools_ncp_model(stan::io::var_context& context__,
                          unsigned int random_seed__ = 0,
                          std::ostream* pstream__ = nullptr) : model_base_crtp(0) {
    typedef double local_scalar_t__;
    boost::ecuyer1988 base_rng__ = 
        stan::services::util::create_rng(random_seed__, 0);
    (void) base_rng__;  // suppress unused var warning
    static const char* function__ = "eight_schools_ncp_model_namespace::eight_schools_ncp_model";
    (void) function__;  // suppress unused var warning
    
    try {
      
      
      current_statement__ = 12;
      J = context__.vals_i("J")[(1 - 1)];
      y = std::vector<double>(J, 0);
      
      current_statement__ = 13;
      pos__ = 1;
      current_statement__ = 13;
      for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
        current_statement__ = 13;
        assign(y, cons_list(index_uni(sym1__), nil_index_list()), context__.vals_r("y")[(pos__ - 1)], "assigning variable y");
        current_statement__ = 13;
        pos__ = (pos__ + 1);}
      sigma = std::vector<double>(J, 0);
      
      current_statement__ = 14;
      pos__ = 1;
      current_statement__ = 14;
      for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
        current_statement__ = 14;
        assign(sigma, cons_list(index_uni(sym1__), nil_index_list()), context__.vals_r("sigma")[(pos__ - 1)], "assigning variable sigma");
        current_statement__ = 14;
        pos__ = (pos__ + 1);}
      current_statement__ = 12;
      current_statement__ = 12;
      check_greater_or_equal(function__, "J", J, 0);
      current_statement__ = 14;
      for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
        current_statement__ = 14;
        current_statement__ = 14;
        check_greater_or_equal(function__, "sigma[sym1__]",
                               sigma[(sym1__ - 1)], 0);}
    } catch (const std::exception& e) {
      stan::lang::rethrow_located(
          std::runtime_error(std::string("inside ctor") + ": " + e.what()), locations_array__[current_statement__]);
      // Next line prevents compiler griping about no return
      throw std::runtime_error("*** IF YOU SEE THIS, PLEASE REPORT A BUG ***"); 
    }
    num_params_r__ = 0U;
    num_params_r__ += 1;
    num_params_r__ += 1;
    num_params_r__ += J;
    
  }
  template <bool propto__, bool jacobian__, typename T__>
  T__ log_prob(std::vector<T__>& params_r__, std::vector<int>& params_i__,
               std::ostream* pstream__ = 0) const {
    typedef T__ local_scalar_t__;
    local_scalar_t__ DUMMY_VAR__(std::numeric_limits<double>::quiet_NaN());
    (void) DUMMY_VAR__;  // suppress unused var warning

    T__ lp__(0.0);
    stan::math::accumulator<T__> lp_accum__;
    static const char* function__ = "eight_schools_ncp_model_namespace::log_prob";
(void) function__;  // suppress unused var warning

    stan::io::reader<local_scalar_t__> in__(params_r__, params_i__);
    
    try {
      local_scalar_t__ mu;
      
      current_statement__ = 2;
      mu = in__.scalar();
      local_scalar_t__ tau;
      
      current_statement__ = 3;
      tau = in__.scalar();
      current_statement__ = 3;
      if (jacobian__) {
        current_statement__ = 3;
        tau = lb_constrain(tau, 0, lp__);
      } else {
        current_statement__ = 3;
        tau = lb_constrain(tau, 0);
      }
      std::vector<local_scalar_t__> theta_tilde;
      theta_tilde = std::vector<local_scalar_t__>(J, 0);
      
      current_statement__ = 4;
      for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
        current_statement__ = 4;
        assign(theta_tilde, cons_list(index_uni(sym1__), nil_index_list()), in__.scalar(
               ), "assigning variable theta_tilde");}
      std::vector<local_scalar_t__> theta;
      theta = std::vector<local_scalar_t__>(J, 0);
      
      current_statement__ = 7;
      for (size_t j = 1; j <= J; ++j) {
        current_statement__ = 6;
        assign(theta, cons_list(index_uni(j), nil_index_list()), (mu + (tau * theta_tilde[(j - 1)])), "assigning variable theta");
      }
      {
        current_statement__ = 8;
        lp_accum__.add(normal_log<propto__>(mu, 0, 5));
        current_statement__ = 9;
        lp_accum__.add(cauchy_log<propto__>(tau, 0, 5));
        current_statement__ = 10;
        lp_accum__.add(normal_log<propto__>(theta_tilde, 0, 1));
        current_statement__ = 11;
        lp_accum__.add(normal_log<propto__>(y, theta, sigma));
      }
    } catch (const std::exception& e) {
      stan::lang::rethrow_located(
          std::runtime_error(std::string("inside log_prob") + ": " + e.what()), locations_array__[current_statement__]);
      // Next line prevents compiler griping about no return
      throw std::runtime_error("*** IF YOU SEE THIS, PLEASE REPORT A BUG ***"); 
    }
    lp_accum__.add(lp__);
    return lp_accum__.sum();
    } // log_prob() 
    
  template <typename RNG>
  void write_array(RNG& base_rng__, std::vector<double>& params_r__,
                   std::vector<int>& params_i__, std::vector<double>& vars__,
                   bool emit_transformed_parameters__ = true,
                   bool emit_generated_quantities__ = true,
                   std::ostream* pstream__ = 0) const {
    typedef double local_scalar_t__;
    vars__.resize(0);
    stan::io::reader<local_scalar_t__> in__(params_r__, params_i__);
    static const char* function__ = "eight_schools_ncp_model_namespace::write_array";
(void) function__;  // suppress unused var warning

    (void) function__;  // suppress unused var warning

    
    try {
      double mu;
      
      current_statement__ = 2;
      mu = in__.scalar();
      double tau;
      
      current_statement__ = 3;
      tau = in__.scalar();
      current_statement__ = 3;
      tau = lb_constrain(tau, 0);
      std::vector<double> theta_tilde;
      theta_tilde = std::vector<double>(J, 0);
      
      current_statement__ = 4;
      for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
        current_statement__ = 4;
        assign(theta_tilde, cons_list(index_uni(sym1__), nil_index_list()), in__.scalar(
               ), "assigning variable theta_tilde");}
      vars__.push_back(mu);
      vars__.push_back(tau);
      for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
        vars__.push_back(theta_tilde[(sym1__ - 1)]);}
      std::vector<double> theta;
      theta = std::vector<double>(J, 0);
      
      if (emit_transformed_parameters__ || emit_generated_quantities__) {
        current_statement__ = 7;
        for (size_t j = 1; j <= J; ++j) {
          current_statement__ = 6;
          assign(theta, cons_list(index_uni(j), nil_index_list()), (mu + (tau * theta_tilde[(j - 1)])), "assigning variable theta");
        }
        for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
          vars__.push_back(theta[(sym1__ - 1)]);}
      } 
    } catch (const std::exception& e) {
      stan::lang::rethrow_located(
          std::runtime_error(std::string("inside write_array") + ": " + e.what()), locations_array__[current_statement__]);
      // Next line prevents compiler griping about no return
      throw std::runtime_error("*** IF YOU SEE THIS, PLEASE REPORT A BUG ***"); 
    }
    } // write_array() 
    
  void transform_inits(const stan::io::var_context& context__,
                       std::vector<int>& params_i__,
                       std::vector<double>& vars__, std::ostream* pstream__) const {
    typedef double local_scalar_t__;
    vars__.resize(0);
    vars__.reserve(num_params_r__);
    
    try {
      int pos__;
      
      double mu;
      
      current_statement__ = 2;
      mu = context__.vals_r("mu")[(1 - 1)];
      double tau;
      
      current_statement__ = 3;
      tau = context__.vals_r("tau")[(1 - 1)];
      current_statement__ = 3;
      tau = lb_free(tau, 0);
      std::vector<double> theta_tilde;
      theta_tilde = std::vector<double>(J, 0);
      
      current_statement__ = 4;
      pos__ = 1;
      current_statement__ = 4;
      for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
        current_statement__ = 4;
        assign(theta_tilde, cons_list(index_uni(sym1__), nil_index_list()), context__.vals_r("theta_tilde")[(pos__ - 1)], "assigning variable theta_tilde");
        current_statement__ = 4;
        pos__ = (pos__ + 1);}
      vars__.push_back(mu);
      vars__.push_back(tau);
      for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
        vars__.push_back(theta_tilde[(sym1__ - 1)]);}
    } catch (const std::exception& e) {
      stan::lang::rethrow_located(
          std::runtime_error(std::string("inside transform_inits") + ": " + e.what()), locations_array__[current_statement__]);
      // Next line prevents compiler griping about no return
      throw std::runtime_error("*** IF YOU SEE THIS, PLEASE REPORT A BUG ***"); 
    }
    } // transform_inits() 
    
  void get_param_names(std::vector<std::string>& names__) const {
    
    names__.resize(0);
    names__.push_back("mu");
    names__.push_back("tau");
    names__.push_back("theta_tilde");
    names__.push_back("theta");
    } // get_param_names() 
    
  void get_dims(std::vector<std::vector<size_t>>& dimss__) const {
    dimss__.resize(0);
    std::vector<size_t> dims__;
    dimss__.push_back(dims__);
    dims__.resize(0);
    dimss__.push_back(dims__);
    dims__.resize(0);
    dims__.push_back(J);
    dimss__.push_back(dims__);
    dims__.resize(0);
    dims__.push_back(J);
    dimss__.push_back(dims__);
    dims__.resize(0);
    
    } // get_dims() 
    
  void constrained_param_names(std::vector<std::string>& param_names__,
                               bool emit_transformed_parameters__ = true,
                               bool emit_generated_quantities__ = true) const {
    
    param_names__.push_back(std::string() + "mu");
    param_names__.push_back(std::string() + "tau");
    for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
      {
        param_names__.push_back(std::string() + "theta_tilde" + '.' + std::to_string(sym1__));
      }}
    if (emit_transformed_parameters__) {
      for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
        {
          param_names__.push_back(std::string() + "theta" + '.' + std::to_string(sym1__));
        }}
    }
    
    if (emit_generated_quantities__) {
      
    }
    
    } // constrained_param_names() 
    
  void unconstrained_param_names(std::vector<std::string>& param_names__,
                                 bool emit_transformed_parameters__ = true,
                                 bool emit_generated_quantities__ = true) const {
    
    param_names__.push_back(std::string() + "mu");
    param_names__.push_back(std::string() + "tau");
    for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
      {
        param_names__.push_back(std::string() + "theta_tilde" + '.' + std::to_string(sym1__));
      }}
    if (emit_transformed_parameters__) {
      for (size_t sym1__ = 1; sym1__ <= J; ++sym1__) {
        {
          param_names__.push_back(std::string() + "theta" + '.' + std::to_string(sym1__));
        }}
    }
    
    if (emit_generated_quantities__) {
      
    }
    
    } // unconstrained_param_names() 
    
  std::string get_constrained_sizedtypes() const {
    stringstream s__;
    s__ << "[{\"name\":\"mu\",\"type\":{\"name\":\"real\"},\"block\":\"parameters\"},{\"name\":\"tau\",\"type\":{\"name\":\"real\"},\"block\":\"parameters\"},{\"name\":\"theta_tilde\",\"type\":{\"name\":\"array\",\"length\":" << J << ",\"element_type\":{\"name\":\"real\"}},\"block\":\"parameters\"},{\"name\":\"theta\",\"type\":{\"name\":\"array\",\"length\":" << J << ",\"element_type\":{\"name\":\"real\"}},\"block\":\"transformed_parameters\"}]";
    return s__.str();
    } // get_constrained_sizedtypes() 
    
  std::string get_unconstrained_sizedtypes() const {
    stringstream s__;
    s__ << "[{\"name\":\"mu\",\"type\":{\"name\":\"real\"},\"block\":\"parameters\"},{\"name\":\"tau\",\"type\":{\"name\":\"real\"},\"block\":\"parameters\"},{\"name\":\"theta_tilde\",\"type\":{\"name\":\"array\",\"length\":" << J << ",\"element_type\":{\"name\":\"real\"}},\"block\":\"parameters\"},{\"name\":\"theta\",\"type\":{\"name\":\"array\",\"length\":" << J << ",\"element_type\":{\"name\":\"real\"}},\"block\":\"transformed_parameters\"}]";
    return s__.str();
    } // get_unconstrained_sizedtypes() 
    
  
    // Begin method overload boilerplate
    template <typename RNG>
    void write_array(RNG& base_rng__,
                     Eigen::Matrix<double,Eigen::Dynamic,1>& params_r,
                     Eigen::Matrix<double,Eigen::Dynamic,1>& vars,
                     bool emit_transformed_parameters__ = true,
                     bool emit_generated_quantities__ = true,
                     std::ostream* pstream = 0) const {
      std::vector<double> params_r_vec(params_r.size());
      for (int i = 0; i < params_r.size(); ++i)
        params_r_vec[i] = params_r(i);
      std::vector<double> vars_vec;
      std::vector<int> params_i_vec;
      write_array(base_rng__, params_r_vec, params_i_vec, vars_vec,
          emit_transformed_parameters__, emit_generated_quantities__, pstream);
      vars.resize(vars_vec.size());
      for (int i = 0; i < vars.size(); ++i)
        vars(i) = vars_vec[i];
    }

    template <bool propto__, bool jacobian__, typename T_>
    T_ log_prob(Eigen::Matrix<T_,Eigen::Dynamic,1>& params_r,
               std::ostream* pstream = 0) const {
      std::vector<T_> vec_params_r;
      vec_params_r.reserve(params_r.size());
      for (int i = 0; i < params_r.size(); ++i)
        vec_params_r.push_back(params_r(i));
      std::vector<int> vec_params_i;
      return log_prob<propto__,jacobian__,T_>(vec_params_r, vec_params_i, pstream);
    }

    void transform_inits(const stan::io::var_context& context,
                         Eigen::Matrix<double, Eigen::Dynamic, 1>& params_r,
                         std::ostream* pstream__) const {
      std::vector<double> params_r_vec;
      std::vector<int> params_i_vec;
      transform_inits(context, params_i_vec, params_r_vec, pstream__);
      params_r.resize(params_r_vec.size());
      for (int i = 0; i < params_r.size(); ++i)
        params_r(i) = params_r_vec[i];
    }

};
}

typedef eight_schools_ncp_model_namespace::eight_schools_ncp_model stan_model;

// Boilerplate
stan::model::model_base& new_model(
        stan::io::var_context& data_context,
        unsigned int seed,
        std::ostream* msg_stream) {
  stan_model* m = new stan_model(data_context, seed, msg_stream);
  return *m;
} 