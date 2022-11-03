using QuanLyBenhAn.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity.Migrations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QuanLyBenhAn.DAO.DAOimpl
{
    public class ServiceDaoImpl : ServiceDao
    {
        private QuanLiHoSoBenhAnNgoaiTruEntities db = new QuanLiHoSoBenhAnNgoaiTruEntities();

        public void Create(object obj)
        {
            if (obj.GetType().Equals(typeof(Service)))
            {
                Service newService = (Service)obj;
                db.Service.Add(newService);
                db.SaveChanges();
            }
        }

        public void Delete(object obj)
        {
            if (obj.GetType().Equals(typeof(Service)))
            {
                Service service = (Service)obj;
                db.Service.Remove(service);
                db.SaveChanges();
            }
        }

        public void Update(object obj)
        {
            if (obj.GetType().Equals(typeof(Service)))
            {
                Service newService = (Service)obj;
                db.Service.AddOrUpdate(newService);
                db.SaveChanges();
            }
        }

        public List<Service> getAll()
        {
            List<Service> services = db.Service.ToList();
            return services;
        }

        public Service getById(string id)
        {
            Service service = db.Service.Where(s => s.serviceID.Equals(id)).FirstOrDefault();
            return service;
        }

        public Service getByName(string name)
        {
            Service service = db.Service.Where(s => s.serviceName.Equals(name)).FirstOrDefault();
            return service;
        }

        public List<Service> Search(string keyword)
        {
            List<Service> services = db.Service.Where(s => s.serviceName.Contains(keyword)).ToList();
            return services;
        }
    }
}
